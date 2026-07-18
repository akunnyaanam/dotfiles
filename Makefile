# Variables
STOW_CMD = stow
PROFILE_FILE = .stow_profile

ifneq ($(wildcard $(PROFILE_FILE)),)
    PACKAGES = $(shell grep -v '^#' $(PROFILE_FILE) | tr '\n' ' ')
else
    PACKAGES = $(shell find . -maxdepth 1 -type d -not -name '.' -not -name '.git' -exec basename {} \;)
endif

# Default target changed to helper manual
.PHONY: all
all: helper

# Target: Prints command manual and interactive options
.PHONY: helper
helper:
	@echo "========================================================================"
	@echo "                     DOTFILES MANAGEMENT MODULE                         "
	@echo "========================================================================"
	@echo "Usage: make <target>"
	@echo ""
	@echo "Available Targets:"
	@echo "  profile   Scan root directory and generate local '.stow_profile'"
	@echo "  link      Deploy active profile configurations as symlinks to ~"
	@echo "  unlink    Purge deployed symlinks cleanly from ~"
	@echo "  relink    Refresh deployment state (unlink followed by link)"
	@echo "  clean     DESTRUCTIVELY DELETE PHYSICAL FILES/DEAD LINKS blocking Stow"
	@echo "  check     Execute non-destructive dry run with high verbosity"
	@echo "  helper    Display this command execution reference guide"
	@echo "========================================================================"
	@echo "Active Profile Packages: $(if $(PACKAGES),$(PACKAGES),[None Loaded])"
	@echo "========================================================================"

# Target: Generate or reset the profile file
.PHONY: profile
profile:
	@echo "# Edit this file to select packages to manage." > $(PROFILE_FILE)
	@echo "# Comment out (#) or delete packages you do not want on this machine." >> $(PROFILE_FILE)
	@for dir in $(shell find . -maxdepth 1 -type d -not -name '.' -not -name '.git' -exec basename {} \;); do \
		echo "$$dir" >> $(PROFILE_FILE); \
	done
	@echo "Generated $(PROFILE_FILE) with available packages."

# Target: Link packages
.PHONY: link
link:
	@if [ -z "$(PACKAGES)" ]; then echo "No packages selected in profile."; exit 1; fi
	@echo "Stowing packages: $(PACKAGES)"
	$(STOW_CMD) --no-folding $(PACKAGES)

# Target: Unlink (Delete symlinks)
.PHONY: unlink
unlink:
	@if [ -z "$(PACKAGES)" ]; then echo "No packages selected in profile."; exit 1; fi
	@echo "Unstowing packages: $(PACKAGES)"
	$(STOW_CMD) -D $(PACKAGES)

# Target: Relink (Unlink then link)
.PHONY: relink
relink: unlink link

# Target: Clean conflicting files (Clear the path)
.PHONY: clean
clean:
	@if [ -z "$(PACKAGES)" ]; then echo "No packages selected in profile."; exit 1; fi
	@echo "Removing conflicting files/dead symlinks from home directory..."
	@for pkg in $(PACKAGES); do \
		if [ -d "$$pkg/.config" ]; then \
			find "$$pkg/.config" -mindepth 1 -maxdepth 2 2>/dev/null | while read -r file; do \
				rel_path=$${file#$$pkg/}; \
				target_path="$(HOME)/$$rel_path"; \
				if [ -e "$$target_path" ] || [ -L "$$target_path" ]; then \
					echo "Removing $$target_path"; \
					rm -rf "$$target_path"; \
				fi; \
			done; \
		fi; \
		find "$$pkg" -maxdepth 1 -name ".*" -not -name "." -not -name ".." 2>/dev/null | while read -r file; do \
			basename=$$(basename "$$file"); \
			target_path="$(HOME)/$$basename"; \
			if [ -e "$$target_path" ] || [ -L "$$target_path" ]; then \
				echo "Removing $$target_path"; \
				rm -rf "$$target_path"; \
			fi; \
		done; \
	done

# Target: Dry-run check simulation
.PHONY: check
check:
	@if [ -z "$(PACKAGES)" ]; then echo "No packages selected in profile."; exit 1; fi
	@echo "Simulating stowing (Dry Run)..."
	$(STOW_CMD) -n -v --no-folding $(PACKAGES)
