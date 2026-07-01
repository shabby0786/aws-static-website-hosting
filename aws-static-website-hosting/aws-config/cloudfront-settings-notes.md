# CloudFront distribution settings used

| Setting | Value |
|---|---|
| Origin domain | S3 bucket REST API endpoint (not the S3 website endpoint) |
| Origin access | Origin Access Control (OAC) — bucket stays fully private |
| Viewer protocol policy | Redirect HTTP to HTTPS |
| Alternate domain names (CNAMEs) | `www.yourdomain.com` |
| Custom SSL certificate | ACM certificate, must be requested in **us-east-1** |
| Minimum TLS version | TLSv1.2_2021 |
| Default root object | `index.html` |
| Price class | Use all edge locations (or restrict to reduce cost, depending on target audience geography) |

## Common mistake to avoid

ACM certificates for CloudFront **must** be requested in the **us-east-1 (N. Virginia)** region, regardless of which region your S3 bucket or other resources are in. A certificate requested in any other region will not show up as selectable when attaching SSL to a CloudFront distribution.
