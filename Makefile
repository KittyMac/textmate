all: build run

build:
	rm -f /Users/rjbowli/build/textmate/release/Applications/TextMate/TextMate.app/Contents/MacOS/spmate
	./configure && ninja TextMate
	cp bin/spmate ~/build/textmate/release/Applications/TextMate/TextMate.app/Contents/MacOS/spmate

run:
	/Users/rjbowli/build/textmate/release/Applications/TextMate/TextMate.app/Contents/MacOS/TextMate

clean:
	rm -r /Users/rjbowli/build/textmate