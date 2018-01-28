src=blog.asc
index=index.html

project=zetafall
user=gmagnusson
host=188.226.132.84

.PHONY: clean

$(index): $(src)
	asciidoctor --backend html5 --out-file $(index) $(src)

post: $(index)
	rsync -avz --delete $(index) $(user)@$(host):blog/.

clean:
	rm -f $(index)
