# Accessibility

## Accessibility py11 command for powershell
- npm install -g pa11y
- pa11y https://example.com

```
pa11y('https://example.com/', {
    actions: [
        'click element #tab-1',
        'wait for element #tab-1-content to be visible',
        'set field #fullname to John Doe',
        'clear field #middlename',
        'check field #terms-and-conditions',
        'uncheck field #subscribe-to-marketing',
        'screen capture example.png',
        'wait for fragment to be #page-2',
        'wait for path to not be /login',
        'wait for url to be https://example.com/',
        'wait for #my-image to emit load',
        'navigate to https://another-example.com/'
    ]
});
```
