# Deployment (Web): Marketing site + Flutter app

This repo is set up to support the recommended split:

- **Marketing site (SEO)** at `/` (static HTML)
- **Flutter app** at `/app/` (built with `flutter build web --base-href /app/`)

## Why this split?

Flutter Web is primarily client-rendered, so search engines usually can't index the real page content of in-app routes as well as they can index HTML pages. Putting SEO pages at `/` gives you fast, indexable pages, while `/app/` remains the product.

## Build the Flutter app for `/app/`

From the repo root:

```bash
flutter build web --release --base-href /app/
```

Upload the output from `build/web/` into your host's `/app/` directory.

## SiteGround / Apache (recommended if you want one domain)

### 1) Marketing site at `/`

Upload the contents of `marketing_site/` to your web root (usually `public_html/`).

### 2) Flutter app at `/app/`

Create a folder `public_html/app/` and upload `build/web/*` there.

### 3) Add rewrite rules for deep links (critical)

Add an `.htaccess` file inside `public_html/app/` with this content:

```apacheconf
<IfModule mod_rewrite.c>
  RewriteEngine On

  # If the request is for an existing file or directory, serve it directly.
  RewriteCond %{REQUEST_FILENAME} -f [OR]
  RewriteCond %{REQUEST_FILENAME} -d
  RewriteRule ^ - [L]

  # Otherwise, route everything to Flutter's entry.
  RewriteRule ^ index.html [L]
</IfModule>
```

This ensures that refreshing a deep link like `/app/products/123` works.

## Cloudflare Pages (free option)

Cloudflare Pages can host *either* the marketing site or the Flutter build output.

### Option A: Separate projects (cleanest)
- Project 1: Marketing site at the root domain
- Project 2: Flutter app at a subdomain, e.g. `app.yourdomain.com`

### Option B: Marketing + `/app` in one project
You can deploy a single artifact that contains:
- marketing files at root
- flutter files in `/app`

If you do that, configure SPA routing for `/app/*` by adding a `_redirects` file at deploy root:

```txt
/app/*  /app/index.html  200
```

## SEO notes

- The Flutter app entry (`web/index.html`) includes `noindex` so it doesn't compete with marketing pages.
- Put your real SEO content (keywords, services, pricing, etc.) on the marketing pages.

