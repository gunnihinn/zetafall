package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"time"
)

// Post is a blog post
type Post struct {
	Title     string
	Content   template.HTML
	Timestamp time.Time
}

// DMY returns day-month-year
func (p Post) DMY() string {
	return p.Timestamp.Format("02-01-2006")
}

func fromJSON(data []byte) (Post, error) {
	p := Post{}
	err := json.Unmarshal(data, &p)

	return p, err
}

func fromFile(filename string) (Post, error) {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		return Post{}, err
	}

	return fromJSON(bytes)
}

func getPosts(dirname string) ([]Post, error) {
	p1, err1 := fromFile("blog/01.json")
	p2, err2 := fromFile("blog/02.json")

	if err1 != nil {
		return []Post{}, err1
	}
	if err2 != nil {
		return []Post{}, err2
	}

	return []Post{p2, p1}, nil
}

var context struct {
	Posts []Post
}

func handler(w http.ResponseWriter, r *http.Request) {
	t, err := template.ParseFiles("index.html")
	if err != nil {
		fmt.Fprintf(w, "Error: %s", err)
	}

	posts, err := getPosts("dir")
	context.Posts = posts
	t.Execute(w, context)
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
