venv_bin=venv/bin/
python=$(venv_bin)python
pip=$(venv_bin)pip3
pycodestyle=$(venv_bin)pycodestyle
pyresttest=$(venv_bin)pyresttest
coverage=$(venv_bin)coverage
bandit=$(venv_bin)bandit
mypy=$(venv_bin)mypy
manage-script=$(CURDIR)/manage.py
manage=$(python) $(manage-script)
db=sqlite
pyvenv=python3 -m venv
yarn=yarn
prod_version=12.0.0

.PHONY: lint
lint:
	$(pycodestyle) $(CURDIR)/TechKiteOFFICEappstore --exclude=migrations,development.py
	$(mypy) --ignore-missing-imports $(CURDIR)/TechKiteOFFICEappstore/api/v1/release
	$(mypy) --ignore-missing-imports $(CURDIR)/TechKiteOFFICEappstore/certificate
	$(bandit) -r $(CURDIR)/TechKiteOFFICEappstore -c $(CURDIR)/.bandit.yml

.PHONY: test
test: lint
	$(yarn) test
	$(coverage) run --source=TechKiteOFFICEappstore $(manage-script) test --settings TechKiteOFFICEappstore.settings.development -v 2
	$(coverage) report --fail-under 90

.PHONY: resetup
resetup:
	rm -f db.sqlite3
	$(MAKE) initdb

.PHONY: initmigrations
initmigrations:
	rm -f $(CURDIR)/TechKiteOFFICEappstore/**/migrations/0*.py
	$(manage) makemigrations --settings TechKiteOFFICEappstore.settings.development

# Only for local setup, do not use in production
.PHONY: dev-setup
dev-setup:
	rm -f db.sqlite3
	$(yarn) install
	$(yarn) run build
	$(pyvenv) venv
	$(pip) install --upgrade pip
	$(pip) install -r $(CURDIR)/requirements/development.txt
	$(pip) install -r $(CURDIR)/requirements/base.txt
ifeq ($(db), postgres)
	$(pip) install -r $(CURDIR)/requirements/production.txt
endif
	cp $(CURDIR)/scripts/development/settings/base.py $(CURDIR)/TechKiteOFFICEappstore/settings/development.py
	cat $(CURDIR)/scripts/development/settings/$(db).py >> $(CURDIR)/TechKiteOFFICEappstore/settings/development.py
	$(MAKE) initdb
	$(MAKE) l10n


.PHONY: initdb
initdb:
	$(manage) migrate --settings TechKiteOFFICEappstore.settings.development
	$(manage) loaddata $(CURDIR)/TechKiteOFFICEappstore/core/fixtures/*.json --settings TechKiteOFFICEappstore.settings.development
	$(manage) createsuperuser --username admin --email admin@admin.com --noinput --settings TechKiteOFFICEappstore.settings.development
	$(manage) verifyemail --username admin --email admin@admin.com --settings TechKiteOFFICEappstore.settings.development
	$(manage) setdefaultadminpassword --settings TechKiteOFFICEappstore.settings.development

.PHONY: docs
docs:
	$(MAKE) -C $(CURDIR)/docs/ clean html

.PHONY: update-dev-deps
update-dev-deps:
	$(pip) install --upgrade -r $(CURDIR)/requirements/development.txt
	$(pip) install --upgrade -r $(CURDIR)/requirements/base.txt
	$(yarn) install --upgrade

.PHONY: authors
authors:
	$(python) $(CURDIR)/scripts/generate_authors.py

.PHONY: clean
clean:
	rm -rf $(CURDIR)/TechKiteOFFICEappstore/core/static/vendor
	rm -rf $(CURDIR)/TechKiteOFFICEappstore/core/static/public
	rm -rf $(CURDIR)/node_modules
	$(MAKE) -C $(CURDIR)/docs/ clean

.PHONY: test-data
test-data: test-user
	PYTHONPATH="${PYTHONPATH}:$(CURDIR)/scripts/" $(python) -m development.testdata

.PHONY: prod-data
prod-data:
	PYTHONPATH="${PYTHONPATH}:$(CURDIR)/scripts/" $(python) -m development.proddata $(prod_version)

.PHONY: l10n
l10n:
	$(manage) compilemessages --settings TechKiteOFFICEappstore.settings.development
	$(manage) importdbtranslations --settings TechKiteOFFICEappstore.settings.development

.PHONY: coverage
coverage:
	$(coverage) html

.PHONY: test-user
test-user:
	$(manage) createtestuser --username user1 --password user1 --email user1@user.com --settings TechKiteOFFICEappstore.settings.development
	$(manage) createtestuser --username user2 --password user2 --email user2@user.com --settings TechKiteOFFICEappstore.settings.development
	$(manage) createtestuser --username user3 --password user3 --email user3@user.com --settings TechKiteOFFICEappstore.settings.development
