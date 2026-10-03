#!/bin/bash
set -e


# Update angular.json safely using python
python3 -c "
import json
with open('$TARGET_DIR/angular.json', 'r+') as f:
    data = json.load(f)
    
    styles = [
        'src/styles.css',
        'node_modules/bootstrap/dist/css/bootstrap.css',
        'node_modules/slick-carousel/slick/slick.scss',
        'node_modules/slick-carousel/slick/slick-theme.scss'
    ]
    scripts = [
        'node_modules/bootstrap/dist/js/bootstrap.js',
        'node_modules/jquery/dist/jquery.min.js',
        'node_modules/slick-carousel/slick/slick.min.js'
    ]
    
    data['projects']['angular-project']['architect']['build']['options']['styles'] = styles
    data['projects']['angular-project']['architect']['build']['options']['scripts'] = scripts
    data['projects']['angular-project']['architect']['test']['options']['styles'] = styles
    data['projects']['angular-project']['architect']['test']['options']['scripts'] = scripts

    f.seek(0)
    json.dump(data, f, indent=2)
    f.truncate()
"
echo "Updated angular.json styles and scripts"
echo "Migration Complete!"
