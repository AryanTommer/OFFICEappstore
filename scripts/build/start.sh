#!/usr/bin/env bash

set -e

chown TechKiteOFFICEappstore:TechKiteOFFICEappstore -R /srv/logs
chown TechKiteOFFICEappstore:TechKiteOFFICEappstore -R /srv/media

# adjust database schema and load new data into it
python manage.py migrate
python manage.py loaddata TechKiteOFFICEappstore/core/fixtures/*.json
python manage.py importdbtranslations

# copy data served by web server data into mounted volume
python manage.py collectstatic --noinput

exec "$@"
