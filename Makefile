NAME = $(shell python setup.py --name)
FULLNAME = $(shell python setup.py --fullname)
DESCRIPTION = $(shell python setup.py --description)
VERSION = $(shell python setup.py --version)
URL = $(shell python setup.py --url)

DOCS_DIR = docs

.PHONY: clean help install docs doc-html doc-pdf dev-install quality release test tox

help:
	@echo '$(NAME) - $(DESCRIPTION)'
	@echo 'Version: $(VERSION)'
	@echo 'URL: $(URL)'
	@echo
	@echo 'Targets:'
	@echo '  help         : display this help text.'
	@echo '  install      : install package $(NAME).'
	@echo '  test         : run all tests.'
	@echo '  tox          : run all tests with tox.'
	@echo '  docs         : generate documentation files.'
	@echo '  quality      : code quality check.'
	@echo '  clean        : remove files created by other targets.'

install:
	pip install --upgrade .

dev-install:
	pip install --upgrade -e .[test]

docs: doc-html doc-pdf

doc-html: test
	cd $(DOCS_DIR); $(MAKE) html

doc-pdf: test
	cd $(DOCS_DIR); $(MAKE) latexpdf

release: quality tox
	@echo 'Checking release version, abort if attempt to release a dev version.'
	echo '$(VERSION)' | grep -qv dev
	@echo 'Bumping version number to $(VERSION), abort if no pending changes.'
	hg commit -m 'Bumped version number to $(VERSION)'
	@echo "Tagging release version $(VERSION), abort if already exists."
	hg tag $(VERSION)
	@echo "Uploading to PyPI."
	python setup.py sdist upload --sign
	@echo "Done."

test:
	py.test

tox:
	tox

quality:
	flake8 .

clean:
	cd $(DOCS_DIR) && $(MAKE) clean
	rm -rf build/ dist/ htmlcov/ *.egg-info MANIFEST $(DOCS_DIR)/conf.pyc *~
