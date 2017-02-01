bin=magnusson
blog=blog
index=index.html

src=main.go

project=magnusson
user=freebsd
host=95.85.32.134

bsd: $(src)
	GOARCH=amd64 GOOS=freebsd go build $(project)

install:
	rsync -avz $(bin) $(blog) $(index) $(user)@$(host):
	ssh $(user)@$(host) 'sudo service magnusson restart'
