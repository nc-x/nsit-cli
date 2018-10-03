import httpclient
import xmltree
import htmlparser
import streams
import nimquery
import strutils
import uri

# Proxy for debugging with Fiddler
# var proxy = newProxy("http://127.0.0.1:8888")

# Headers 'Referer' and 'User-Agent' are required
var headers = newHttpHeaders()
headers.add("Referer", "https://imsnsit.org/imsnsit/")
headers.add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36")


var client = newHttpClient(maxredirects = 0) # , proxy = proxy) | Uncomment if debugging with Fiddler

# GET request to the student_login.php url WITH the headers
var response = client.request(url = "https://imsnsit.org/imsnsit/student_login.php", httpmethod = "GET", headers = headers )

# Take the cookies from the Response and add that to the next Request
var cookie = response.headers["set-cookie"].split(";")[0]
headers.add("Cookie", cookie)

# Getting the relative url of the captcha image
let xml = parseHtml(newStringStream(response.body))
let elements = xml.querySelectorAll("#captchaimg")

# 'elements' is an array, so we access 0th index, and use 'attr' function to get the value of the 'src' attribute
var captcha_url = "https://imsnsit.org/imsnsit/" & elements[0].attr("src")

# Do a GET request to the captcha_url and Write the FILE to your computer
writeFile("captcha.jpg", newHttpClient().get(captcha_url).body)

# Take user input for captcha value
echo "Enter captcha value: "
var captcha_user_input = encodeUrl(readLine(stdin))


echo "Enter your user id: "
var id = encodeUrl(readLine(stdin))
echo "Enter your password: "
var password = encodeUrl(readLine(stdin))

# Body for the POST request.
var body = "f=&uid=" & id & "&pwd=" & password & "&fy=2017-18&comp=NETAJI+SUBHAS+INSTITUTE+OF+TECHNOLOGY&cap=" & captcha_user_input & "&logintype=student"

# For POST request, also add a 'Content-Type' field with value 'application/x-www-form-urlencoded'
headers.add("Content-Type", "application/x-www-form-urlencoded")

# Do a POST request to the url with the headers, cookies and the body
response = client.request(url = "https://imsnsit.org/imsnsit/student_login.php", httpmethod = "POST", headers = headers, body = body )

# If successfully logged in, the Response Headers contain a 'location' field which points to the next url
# So concatenate the base url and location to get final url
var nexturl = "https://imsnsit.org/imsnsit/" & response.headers["location"]

# The 'Content-Type' header is not required anymore, so delete it
headers.del("Content-Type")

# Do a GET request to the 'nexturl' with the headers and cookies
response = client.request(url = nexturl, httpmethod = "GET", headers = headers )

# The response body contains the HTML of the logged in page.
echo response.body

# Scrape the url's of the 'My Profile', etc etc.
