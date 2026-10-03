// The carousel library's ngOnDestroy removes window event listeners.
// Patch it here so JSDOM teardown doesn't throw "window is not defined".
import { CarouselComponent as NgxCarouselEase } from 'ngx-carousel-ease';
NgxCarouselEase.prototype.ngOnDestroy = function () {};

import { TestBed } from '@angular/core/testing';
import { App } from './app';

describe('App (shell)', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [App],
    }).compileComponents();
  });

  // ── Smoke ────────────────────────────────────────────────────────────────

  it('should create the app', () => {
    const fixture = TestBed.createComponent(App);
    expect(fixture.componentInstance).toBeTruthy();
  });

  // ── Section presence ─────────────────────────────────────────────────────
  // One assertion per major page section.  Catches a misplaced import,
  // wrong selector, or accidentally-removed tag from app.html.

  it('should render <app-header>', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('app-header')).toBeTruthy();
  });

  it('should render <app-carousel>', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('app-carousel')).toBeTruthy();
  });

  it('should render <app-partners>', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('app-partners')).toBeTruthy();
  });

  it('should render <app-offering>', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('app-offering')).toBeTruthy();
  });

  it('should render <app-footer>', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('app-footer')).toBeTruthy();
  });
});

