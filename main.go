package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"os"
	"path"
	"sort"
	"time"

	"github.com/russross/blackfriday"
)

// ByDate implements sort.Interface for []Post
type ByDate []Post

func (a ByDate) Len() int           { return len(a) }
func (a ByDate) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a ByDate) Less(i, j int) bool { return a[i].Timestamp.After(a[j].Timestamp) }

// Post is a blog post
type Post struct {
	Title       string
	Content     string
	HTMLContent template.HTML
	Timestamp   time.Time
}

// DMY returns day-month-year
func (p Post) DMY() string {
	return p.Timestamp.Format("02-01-2006")
}

func fromJSON(data []byte) (Post, error) {
	p := Post{}
	err := json.Unmarshal(data, &p)
	if err != nil {
		err = fmt.Errorf("Error '%s' while decoding '%s'", err, data)
		return Post{}, err
	}

	p.HTMLContent = template.HTML(blackfriday.MarkdownCommon([]byte(p.Content)))

	return p, nil
}

func fromFile(filename string) (Post, error) {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		return Post{}, err
	}

	return fromJSON(bytes)
}

func getPosts(dirname string) ([]Post, error) {
	files, err := ioutil.ReadDir(dirname)
	if err != nil {
		return []Post{}, err
	}

	posts := make([]Post, 0, len(files))
	for _, file := range files {
		post, err := fromFile(path.Join(dirname, file.Name()))
		if err != nil {
			return []Post{}, err
		}
		posts = append(posts, post)
	}

	sort.Sort(ByDate(posts))
	return posts, nil
}

var context struct {
	Posts []Post
	Error error
}

func getHandler(dir string, err error) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		if err != nil {
			fmt.Fprintf(w, "Error: %s", err)
			return
		}

		t, err := template.ParseFiles(path.Join(dir, "index.html"))
		if err != nil {
			fmt.Fprintf(w, "Error: %s", err)
			return
		}

		posts, err := getPosts(path.Join(dir, "blog"))
		context.Posts = posts
		context.Error = err
		t.Execute(w, context)
	}
}

func blogDir(args []string) (string, error) {
	if len(args) > 0 {
		return args[0], nil
	}
	return os.Getwd()
}

func main() {
	var port = flag.Int("port", 8080, "HTTP port")
	flag.Parse()

	blogdir, err := blogDir(flag.Args())
	http.HandleFunc("/", getHandler(blogdir, err))
	http.ListenAndServe(fmt.Sprintf(":%d", *port), nil)
}
