.PHONY:  clean build

# Binary name
BINARY=jd-cli

# Builds the project
build:
		@for project in $$(ls cmd); \
		do \
			go build -ldflags "-w -s -X main.Version=${VERSION}" "./cmd/$$project"; \
			upx "./$$project"; \
		done


release:
		# Clean
		go clean
		rm -rf *.gz

		# Build for mac
		@for project in $$(ls cmd); \
		do \
			GO111MODULE=on go build -ldflags "-w -s -X main.Version=${VERSION}" "./cmd/$$project"; \
			upx "./$$project"; \
			tar czvf $$project-mac64-${VERSION}.tar.gz ./$$project; \
		done


		# Build for linux
		go clean
		@for project in $$(ls cmd); \
		do \
			CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -ldflags "-w -s -X main.Version=${VERSION}" "./cmd/$$project"; \
			upx "./$$project"; \
			tar czvf $$project-linux64-${VERSION}.tar.gz ./$$project; \
		done

		go clean

# Cleans our projects: deletes binaries
clean:
		@for project in $$(ls cmd); \
		do \
			rm -rf $$project; \
		done
		go clean
		rm -rf *.gz
