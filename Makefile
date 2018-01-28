src=blog.asc
style=style.css
index=index.html

project=zetafall
user=gmagnusson
host=188.226.132.84

.PHONY: clean

$(index): $(src) $(style)
	asciidoctor --backend html5 -a stylesheet=style.css --out-file $(index) $(src)

post: $(index)
	rsync -avz --delete $(index) $(user)@$(host):blog/.

clean:
	rm -f $(index)
