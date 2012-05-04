## console-tweet

Tweet from the console.
Meant to be as simple as possible.

---

### installation

    gem install console_tweet

---

### setup

    twitter setup

You'll be prompted to open a browser to OAuth (opens automatically
on Mac OS) Twitter for console_tweet

---

### send a tweet

    $ twitter tweet "hello world"
    $ echo 'hello world' | twitter tweet

    # or to be prompted, use:
    $ twitter tweet

---

### view your timeline, since last view

    twitter

### view most recent status

    twitter status

### view the most recent replies / mentions

    twitter replies

---

### Coming soon:

* Support for multiple accounts
* URL Shortening support

---

### Authors

* John Crepezzi <john.crepezzi@gmail.com>
* Justin Campbell
* José Manuel

---

### License

(The MIT License)

Copyright (c) 2010 John Crepezzi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
