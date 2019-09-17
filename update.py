#! /usr/bin/env python3

import os
import datetime
import platform
import inspect
from pathlib import Path
from subprocess import check_output, CalledProcessError  # nosec

from gitignore_parser import parse_gitignore
from logzero import logger, logging, loglevel

home_dir = Path(os.environ['HOME'])
script_dir = Path(os.path.dirname(os.path.realpath(__file__)))
gitignore = parse_gitignore(script_dir / '.gitignore')
system = platform.system()


class UpdateError(BaseException):
    """ Raised for errors during dotfile update process.

    Attributes:
        stage - Stage where the error happened
        message - Explanation
    """

    def __init__(self, stage, message):
        self.stage = stage
        self.message = message


# Gets the expected directory for pictures, depending on the OS
def get_picture_dir():
    if system == "Linux":
        return home_dir / "pictures"
    elif system == "Darwin":
        return home_dir / "Pictures"
    else:
        raise UpdateError("root-mapping", "Unknown OS: {}".format(system))


# Gets the expected directory for pictures, depending on the OS
def get_documents_dir():
    if system == "Linux":
        return home_dir / "docs"
    elif system == "Darwin":
        return home_dir / "Documents"
    else:
        raise UpdateError("root-mapping", "Unknown OS: {}".format(system))


# Gets the expected directory for config files, depending on the OS
def get_config_dir():
    if system == "Linux":
        return home_dir / ".config"
    elif system == "Darwin":
        return home_dir / ".config"
    else:
        raise UpdateError("config-mapping", "Unknown OS: {}".format(system))


# Gets the expected directory for config files, depending on the OS
def get_bin_dir():
    if system == "Linux":
        return home_dir / "bin"
    elif system == "Darwin":
        return home_dir / "bin"
    else:
        raise UpdateError("bin-mapping", "Unknown OS: {}".format(system))


# Mapping for configuration files
config_mapping = {
    "Xresources": home_dir / ".Xresources",
    "alacritty": get_config_dir() / "alacritty",
    "dracut.conf": Path("/etc/dracut.conf"),
    "fstab": Path("/etc/fstab"),
    "genkernel.conf": Path("/etc/genkernel.conf"),
    "grub": Path("/etc/default/grub"),
    "gopass": get_config_dir() / "gopass",
    "i3": get_config_dir() / "i3",
    "i3status-rs.toml": get_config_dir() / "i3status-rs.toml",
    "make.conf": Path("/etc/portage/make.conf"),
    "mako": get_config_dir() / "mako",
    "nvim": get_config_dir() / "nvim",
    "rofi": get_config_dir() / "rofi",
    "sway": get_config_dir() / "sway",
    "swaylock": get_config_dir() / "swaylock",
    "tlp.conf": Path("/etc/tlp.conf"),
    "tmux": get_config_dir() / "tmux",
    "vconsole.conf": Path("/etc/vconsole.conf"),
    "xinitrc": home_dir / ".xinitrc",
    "zshrc": home_dir / ".zshrc",
}

# Mapping scripts
bin_mapping = {
    "aim": get_bin_dir() / "aim",
    "menu": get_bin_dir() / "menu",
    "bimp": get_bin_dir() / "bimp",
    "checkiommu": get_bin_dir() / "checkiommu",
    "fixhd": get_bin_dir() / "fixhd",
    "fuzzylock": get_bin_dir() / "fuzzylock",
    "nker": get_bin_dir() / "nker",
    "passmenu": get_bin_dir() / "passmenu",
    "prtsc": get_bin_dir() / "prtsc",
    "testfonts": get_bin_dir() / "testfonts",
    "wm": get_bin_dir() / "wm",
}

# Mapping for dotfiles (root) directory.
# Semantic map:
# None - Ignore
# Path - Copy
# dict - Handle as (nested) mapping
root_mapping = {
    ".gitignore": None,
    ".gitattributes": None,
    "LICENSE": None,
    "Pipfile": None,
    "README.md": None,
    "bin": bin_mapping,
    "config": config_mapping,
    "update.py": None,
    "kernel": None,
    "walls": get_picture_dir() / "walls",
    "papers": get_documents_dir() / "papers"
}


def run(cmd):
    logger.debug(cmd)
    try:
        output = check_output(cmd)  # nosec
        logger.debug(output)
        return True
    except CalledProcessError:
        return False


def git_pull():
    """
        Pulls git origin
    """
    cmd = ["git", "pull"]
    return run(cmd)


def git_add(path):
    """
        Stages file in `path`
    """
    cmd = ["git", "add", str(path)]
    return run(cmd)


def git_commit(msg):
    """
        Commits with `msg`
    """
    cmd = ["git", "commit", "-m", str(msg)]
    return run(cmd)


def git_push():
    """
        Pushes to git origin
    """
    cmd = ["git", "push"]
    return run(cmd)


def handle_copy(src, dst):
    """
        Copies file or directory. In the latter it will delete files in the
        destination not in the source.
    """
    # Work around the fact that rsync is weird
    if Path(src).is_dir():
        src = str(src) + '/'
    # Construct the command, ignore links and purge outdated files
    cmd = ["rsync", "-Pav", "--no-links", "--delete", str(src),
           str(dst)]
    return run(cmd)


def update_mapping(root, mapping):
    """
        Transverse a mapping, copying leaf nodes to their destination
    """
    # Mildly nasty
    if len(inspect.stack()) == 2:
        logger.info("Updating root mapping")
    logger.debug(">>>> Mapping with root {}".format(root))
    # Recursively iterate over the mapping
    for node in mapping:
        value = mapping[node]
        if isinstance(value, dict):
            logger.info("Updating {} mapping".format(node))
            new_root = Path(root) / str(node)
            update_mapping(new_root, value)
        elif isinstance(value, Path):
            logger.debug("Copying {}".format(node))
            # Skip & report broken nodes
            if not value.exists():
                continue
            # Construct node & value paths
            node_path = Path(root) / str(node)
            value_path = Path(value)
            if value_path.is_dir():
                value_path.mkdir(parents=True, exist_ok=True)
            # Finaly perform the copy
            ok = handle_copy(value_path, node_path)
            if not ok:
                logger.error("Update failed for {}".format(node))
        else:
            logger.debug("Skipping {}".format(node))


def verify_mapping(root, mapping):
    """
        Transverse root, enforcing all files in repo are represented in
        mappings.
    """
    # Mildly nasty
    if len(inspect.stack()) == 2:
        logger.info("Verifying root mapping")
    for elem in Path(root).iterdir():
        # Make sure we're only verifying valid files
        if gitignore(elem) or elem.parts[-1] == '.git':
            continue
        # The node names are just the last element in the path
        node = elem.parts[-1]
        # Warns about a file with no mapping
        if node not in mapping:
            logger.error(
                "'{}' is not represented in any mapping!".format(node))
            continue
        if isinstance(mapping[node], dict):
            logger.info("Verifying {} mapping".format(node))
            new_root = Path(root) / node
            verify_mapping(new_root, mapping[node])


def sync_mapping(root, mapping):
    """
        Transverse mapping, staging changes to mapped files and syncing them to
        git.
    """
    loglevel(level=logging.DEBUG)
    if len(inspect.stack()) == 2:
        logger.info("Syncing root mapping")
    for node in mapping:
        value = mapping[node]
        if isinstance(value, dict):
            logger.info("Syncing {} mapping".format(node))
            new_root = Path(root) / str(node)
            sync_mapping(new_root, value)
        elif isinstance(value, Path):
            node_path = Path(root) / str(node)
            root_path_length = len(script_dir.parts)
            object_path = Path("/".join(node_path.parts[root_path_length:]))
            ok = git_add(object_path)
            if not ok:
                continue
            now = datetime.datetime.now().strftime("%Y-%m-%d-%H:%M:%S-%Z")
            category = str(node_path.parts[-2])
            name = str(node_path.parts[-1])
            msg = "{}/{}: sync @ {}".format(category, name, now)
            git_commit(msg)
        else:
            logger.debug("Skipping {}".format(node))
    pass


loglevel(level=logging.INFO)
update_mapping(script_dir, root_mapping)
verify_mapping(script_dir, root_mapping)
sync_mapping(script_dir, root_mapping)
