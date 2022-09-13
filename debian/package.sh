#!/bin/bash
rm ./*.deb

/usr/bin/env git clone https://github.com/samicrusader/qomui.git qomui-build
cd qomui-build
version="$(git describe --long --tags | sed 's/^v//;s/\([^-]*-\)g/r\1/;s/-/./g')"
pkgdir=python3-qomui_"$version"_all
mkdir -p "../$pkgdir/DEBIAN"
/usr/bin/env python3 setup.py build
/usr/bin/env python3 setup.py test
/usr/bin/env python3 setup.py install --root="../$pkgdir" --optimize=1 --skip-build
cd ./..
mkdir -p "$pkgdir/usr/lib/python3/dist-packages"
mv "$pkgdir"/usr/lib/python3.*/site-packages/qomui* "$pkgdir/usr/lib/python3/dist-packages"
rm -r "$pkgdir"/usr/lib/python3.*
size="$(du --apparent-size --block-size=K --summarize "$pkgdir/usr/" | cut -f -1)"

cp {control,postinst,prerm} "$pkgdir/DEBIAN"
/usr/bin/env sed -i "s/xversion/$version/g" "$pkgdir/DEBIAN/control"
/usr/bin/env sed -i "s/in_kb/$size/g" "$pkgdir/DEBIAN/control"
/usr/bin/env dpkg-deb --build --root-owner-group "$pkgdir"
rm -rf qomui-build "$pkgdir"