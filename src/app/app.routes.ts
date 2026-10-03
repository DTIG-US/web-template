import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./web-home/home.component').then(m => m.HomeComponent),
    title: 'COMPANY_NAME_HERE - Page Title'
  },
  {
    path: 'privacy-policy',
    loadComponent: () =>
      import('./web-legal/privacy-policy/privacy-policy.component').then(m => m.PrivacyPolicyComponent),
    title: 'Privacy Policy | COMPANY_NAME_HERE'
  },
  {
    path: 'terms-of-service',
    loadComponent: () =>
      import('./web-legal/terms-of-service/terms-of-service.component').then(m => m.TermsOfServiceComponent),
    title: 'Terms of Service | COMPANY_NAME_HERE'
  },
  {
    path: '**',
    loadComponent: () =>
      import('./web-not-found/not-found.component').then(m => m.NotFoundComponent),
    title: '404 | COMPANY_NAME_HERE'
  }
];
