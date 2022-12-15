# qr generate+send

This quick and dirty script processes a simple ; delimited csv files to:

- Extract data from the csv (name, surname, email, url)
- Shorten the URL using tinyurl
- Generate a QR for the url and shortened url (in png format)
- Add some text info to the generated pngs
- Convert the png files to their pdf versions
- Customize email body text
- Send email with attached png's and pdf's


# Requirements

The script requires imagemagick `convert`, `qrencode`, `curl` and `mutt`.


# Notes

If you get an error when converting from png to pdf using `convert`, continue reading.

To make convert work from png to pdf, there is a known bug in old ghostcript versions.
See https://stackoverflow.com/questions/52998331/imagemagick-security-policy-pdf-blocking-conversion for further info.

In my case, this is the relevant section I applied:

On Ubuntu 19.04 through 22.04 and probably any later versions coming with ImageMagick 6, here's how you fix the issue by removing that workaround:

Make sure you have Ghostscript ≥9.24:

gs --version
If yes, just remove this whole following section from /etc/ImageMagick-6/policy.xml:

<!-- disable ghostscript format types -->
<policy domain="coder" rights="none" pattern="PS" />
<policy domain="coder" rights="none" pattern="PS2" />
<policy domain="coder" rights="none" pattern="PS3" />
<policy domain="coder" rights="none" pattern="EPS" />
<policy domain="coder" rights="none" pattern="PDF" />
<policy domain="coder" rights="none" pattern="XPS" />
