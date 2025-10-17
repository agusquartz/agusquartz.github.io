# HW06 Git Github NodeJS Deploy in Github Pages

- Small frontend to authenticate to mini-erp and retrieve some products
- I didn't use Github Actions to deploy because Github pages deploy static sites by itself with each push

## LIVE DEMO
**Github Pages**: https://agusquartz.github.io/

It may not work because github pages is https and the api is http, so just consider that...
To fix it, download the site and run it locally

## Technologies
- HTML + CSS + JAVASCRIPT: No Frameworks used

## Functionalities
- **Login**: (email + password)
- **Profile**: session validation
- **Products**: GET /api/inventory/products/ -> Then show them in the table
- **Logout**: Cleans the session

## Used ENDPOINTS
- POST /api/users/users/login/
- GET /api/users/users/profile/
- GET /api/inventory/products/

## Test Credentials
- admin@minierp.com / test123456

## Mini-ERP Credits
https://github.com/Piuliss/mini-erp


## OTHERS (huffman doc)
- **Github Pages**: https://agusquartz.github.io/HUFFMAN