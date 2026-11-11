#!/bin/bash
set -e

SRC_DIR="/home/b0nz1cu5/Development/IH/dtig-web"
TARGET_DIR="/home/b0nz1cu5/Development/IH/ih-hand-sanitation-www"

echo "Starting Migration..."

# 1. Update Root Template (app.html)
cat << 'EOF' > "$TARGET_DIR/src/app/app.html"
<app-header></app-header>

<app-carousel></app-carousel>

<app-partners></app-partners>

<app-offering></app-offering>

<app-footer></app-footer>
EOF
echo "Updated app.html"

# 2. Make Components Standalone
# Header
sed -i 's/import { Component, OnInit } from '"'"'@angular\/core'"'"';/import { Component, OnInit } from '"'"'@angular\/core'"'"';\nimport { CommonModule } from '"'"'@angular\/common'"'"';/' "$TARGET_DIR/src/app/web-header/header.component.ts"
sed -i 's/selector: '"'"'app-header'"'"',/selector: '"'"'app-header'"'"',\n  standalone: true as boolean,\n  imports: [CommonModule],/' "$TARGET_DIR/src/app/web-header/header.component.ts"

# Carousel
sed -i 's/import { Component } from '"'"'@angular\/core'"'"';/import { Component } from '"'"'@angular\/core'"'"';\nimport { CommonModule } from '"'"'@angular\/common'"'"';\nimport { SlickCarouselModule } from '"'"'ngx-slick-carousel'"'"';/' "$TARGET_DIR/src/app/web-carousel/carousel.component.ts"
sed -i 's/selector: '"'"'app-carousel'"'"',/selector: '"'"'app-carousel'"'"',\n  standalone: true as boolean,\n  imports: [CommonModule, SlickCarouselModule],/' "$TARGET_DIR/src/app/web-carousel/carousel.component.ts"

# Partners
sed -i 's/import { Component } from '"'"'@angular\/core'"'"';/import { Component } from '"'"'@angular\/core'"'"';\nimport { CommonModule } from '"'"'@angular\/common'"'"';\nimport { SlickCarouselModule } from '"'"'ngx-slick-carousel'"'"';/' "$TARGET_DIR/src/app/web-partner/partners.component.ts"
sed -i 's/selector: '"'"'app-partners'"'"',/selector: '"'"'app-partners'"'"',\n  standalone: true as boolean,\n  imports: [CommonModule, SlickCarouselModule],/' "$TARGET_DIR/src/app/web-partner/partners.component.ts"
echo "Converted components to standalone"

# Offering
sed -i 's/import { Component } from '"'"'@angular\/core'"'"';/import { Component } from '"'"'@angular\/core'"'"';\nimport { CommonModule } from '"'"'@angular\/common'"'"';\nimport { SlickCarouselModule } from '"'"'ngx-slick-carousel'"'"';/' "$TARGET_DIR/src/app/web-offering/offering.component.ts"
sed -i 's/selector: '"'"'app-offering'"'"',/selector: '"'"'app-offering'"'"',\n  standalone: true as boolean,\n  imports: [CommonModule, SlickCarouselModule],/' "$TARGET_DIR/src/app/web-offering/offering.component.ts"
echo "Converted components to standalone"

# Footer
sed -i 's/import { Component } from '"'"'@angular\/core'"'"';/import { Component } from '"'"'@angular\/core'"'"';\nimport { CommonModule } from '"'"'@angular\/common'"'"';\nimport { SlickCarouselModule } from '"'"'ngx-slick-carousel'"'"';/' "$TARGET_DIR/src/app/web-footer/footer.component.ts"
sed -i 's/selector: '"'"'app-footer'"'"',/selector: '"'"'app-footer'"'"',\n  standalone: true as boolean,\n  imports: [CommonModule, SlickCarouselModule],/' "$TARGET_DIR/src/app/web-footer/footer.component.ts"
echo "Converted components to standalone"

# 3. Update App Component (app.ts)
sed -i 's/import { RouterOutlet } from '"'"'@angular\/router'"'"';/import { RouterOutlet } from '"'"'@angular\/router'"'"';\nimport { HeaderComponent } from '"'"'.\/web-header\/header.component'"'"';\nimport { CarouselComponent } from '"'"'.\/web-carousel\/carousel.component'"'"';\nimport { PartnersComponent } from '"'"'.\/web-partner\/partners.component'"'"';/' "$TARGET_DIR/src/app/app.ts"
sed -i 's/imports: \[RouterOutlet\]/imports: [RouterOutlet, HeaderComponent, CarouselComponent, PartnersComponent, OfferingComponent, FooterComponent]/' "$TARGET_DIR/src/app/app.ts"
echo "Updated app.ts imports"

# 4. Copy CSS files
cp "$SRC_DIR/src/styles.css" "$TARGET_DIR/src/styles.css"
cp "$SRC_DIR/src/app/web-carousel/carousel.component.css" "$TARGET_DIR/src/app/web-carousel/carousel.component.css"
cp "$SRC_DIR/src/app/web-offering/offering.component.css" "$TARGET_DIR/src/app/web-offering/offering.component.css"
cp "$SRC_DIR/src/app/web-footer/footer.component.css" "$TARGET_DIR/src/app/web-footer/footer.component.css"
echo "Copied CSS files"

# 5. Fix Carousel HTML
cat << 'EOF' > "$TARGET_DIR/src/app/web-carousel/carousel.component.html"
<section class="mt-4">
  <div class="container-fluid">
    <div class="row">
      <div class="col-md-9 bg-white">
        <div class="row">
          <div class="col-md-12 m-4">
            <img src="{{data.carouselImage}}" />
          </div>
        </div>

       <div class="row test">
         <div class="col-md-12">
           <ngx-slick-carousel class="carousel mx-5"
                               #slickModal="slick-carousel"
                               [config]="slideConfig"
                               (init)="slickInit($event)"
                               (breakpoint)="breakpoint($event)"
                               (afterChange)="afterChange($event)"
                               (beforeChange)="beforeChange($event)">
             <div ngxSlickItem class="slide text-center" *ngFor="let item of news.carousel">
               <h1>{{item.title}}</h1>
               <h4>{{item.label}}</h4>
               <p class="slide-item">{{item.description}}</p>
             </div>


           </ngx-slick-carousel>
         </div>
       </div>


      </div>
      <div class="col-md-3 bg-black">
        <h2 class="text-center text-white">News</h2>
        <div class="card bg-transparent">
          <div class="card-body text-white" *ngFor="let item of news.news">
            <a href="{{item.url}}" class="text-white text-decoration-none"  target="_blank" >{{item.title}}</a>
          </div>

        </div>
      </div>

    </div>
  </div>
</section>
EOF
echo "Fixed carousel HTML"

# 6. Update angular.json safely using python
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
