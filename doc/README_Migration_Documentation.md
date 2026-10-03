# Migration Documentation: dtig-web to ih-hand-sanitation-www

This document outlines the step-by-step process we followed to migrate the layout, components, and styling from `dtig-web` to `ih-hand-sanitation-www` to make them look identical.

## 1. Root Template Layout Update
**Issue:** `ih-hand-sanitation-www` displayed a blank page because it relied on an empty routing configuration (`<router-outlet>`).
**Fix:** We updated `src/app/app.html` to explicitly include the layout components before the router outlet:
```html
<app-header></app-header>
<app-carousel></app-carousel>
<app-partners></app-partners>
<router-outlet></router-outlet>
```

## 2. Converting Components to Standalone
**Issue:** Angular 15 standalone root components cannot import standard components without an `NgModule`.
**Fix:** We converted the layout components to standalone components by modifying their `@Component` decorators:
- **HeaderComponent**: Added `standalone: true as boolean` and `imports: [CommonModule]`.
- **CarouselComponent**: Added `standalone: true as boolean` and `imports: [CommonModule, SlickCarouselModule]`.
- **PartnersComponent**: Added `standalone: true as boolean` and `imports: [CommonModule, SlickCarouselModule]`.

## 3. Registering Components in App
**Issue:** The newly standalone components needed to be registered with the root application.
**Fix:** We imported `HeaderComponent`, `CarouselComponent`, and `PartnersComponent` into the `imports` array of the `App` component in `src/app/app.ts`.

## 4. CSS and Styling Sync
**Issue:** The new project lacked the global and component-specific styling from `dtig-web`.
**Fix:** 
- Copied `src/styles.css` from `dtig-web` to `ih-hand-sanitation-www`.
- Copied `src/app/web-carousel/carousel.component.css` from `dtig-web` to `ih-hand-sanitation-www`.

## 5. Angular Workspace Configuration (angular.json)
**Issue:** Bootstrap, jQuery, and Slick Carousel styles/scripts were missing from the build process.
**Fix:** Updated `angular.json` in `ih-hand-sanitation-www` to match `dtig-web`'s `styles` and `scripts` arrays for both the `build` and `test` targets:
```json
"styles": [
  "src/styles.css",
  "node_modules/bootstrap/dist/css/bootstrap.css",
  "node_modules/slick-carousel/slick/slick.scss",
  "node_modules/slick-carousel/slick/slick-theme.scss"
],
"scripts": [
  "node_modules/bootstrap/dist/js/bootstrap.js",
  "node_modules/jquery/dist/jquery.min.js",
  "node_modules/slick-carousel/slick/slick.min.js"
]
```

## 6. Carousel Data Mapping Fix
**Issue:** The carousel component had a mismatch in its data binding compared to `data.json`.
**Fix:** Updated `src/app/web-carousel/carousel.component.html`:
- Changed the `*ngFor` loop from `news.home.carousel` to `news.carousel`.
- Removed a missing `<img src="{{item.image}}">` tag since the JSON data didn't contain an `image` property for slides.
