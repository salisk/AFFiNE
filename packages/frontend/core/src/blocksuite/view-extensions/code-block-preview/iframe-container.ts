export function linkIframe(iframe: HTMLIFrameElement, html: string) {
  // Self-hosted: Use srcdoc instead of loading from external server
  // This eliminates phone-home to affine.run
  iframe.sandbox.add(
    'allow-pointer-lock',
    'allow-popups',
    'allow-forms',
    'allow-popups-to-escape-sandbox',
    'allow-downloads',
    'allow-scripts',
    'allow-same-origin'
  );

  // Create a complete HTML document with the user's HTML
  const containerHTML = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      margin: 0;
      padding: 8px;
      font-family: system-ui, -apple-system, sans-serif;
    }
  </style>
</head>
<body>
  ${html}
</body>
</html>`;

  // Use srcdoc to render inline without external requests
  iframe.srcdoc = containerHTML;
}
