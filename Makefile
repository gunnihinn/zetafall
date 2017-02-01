bin=magnusson
blog=blog
index=index.html

src=main.go

project=magnusson
user=freebsd
host=95.85.32.134

$(bin): $(src)
	GOARCH=amd64 GOOS=freebsd go build $(project)

post:
	rsync -avz $(blog) $(index) $(user)@$(host):

install: $(bin)
	rsync -avz $(bin) $(user)@$(host):
	ssh $(user)@$(host) 'sudo service magnusson restart'

clean:
	rm -f $(bin)
