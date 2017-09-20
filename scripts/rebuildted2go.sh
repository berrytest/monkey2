
source common.sh

echo ""
echo "***** Rebuilding ted2 *****"
echo ""

$mx2cc makeapp -clean -apptype=gui -build -config=release -product=scripts/ted2go.products/$host/Ted2 ../src/ted2go/Ted2.monkey2

$mx2cc makeapp -clean -apptype=gui -build -config=release -product=scripts/launcher.products/$host/Launcher ../src/launcher/launcher.monkey2

if [ "$OSTYPE" = "linux-gnu" ]
then

	rm -r -f "$ted2"
	mkdir "$ted2"
	cp -R "$ted2go_new/assets" "$ted2/assets"
	cp "$ted2go_new/Ted2" "$ted2/ted2"
	rm -r -f "$launcher"
	cp "$launcher_new" "$launcher"

elif [ "$OSTYPE" = "linux-gnueabihf" ]
then

	rm -r -f "$ted2"
	mkdir "$ted2"
	cp -R "$ted2go_new/assets" "$ted2/assets"
	cp "$ted2go_new/Ted2" "$ted2/ted2"
	rm -r -f "$launcher"
	cp "$launcher_new" "$launcher"

else

	rm -r -f $ted2
	cp -R ./ted2go.products/macos/Ted2.app $ted2
	
	rm -r -f "$launcher"
	cp -R ./launcher.products/macos/Launcher.app "$launcher"
	
	cp ../src/launcher/info.plist "$launcher/Contents"
	cp ../src/launcher/Monkey2logo.icns "$launcher/Contents/Resources"

fi
