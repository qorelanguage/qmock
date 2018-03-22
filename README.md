# QMock module
QMock is module of the Qore language see https://github.com/qorelanguage/qore

## Introduction

QMock is a module for testing in Qore. It allows you to mock methods of objects and make assertions about how they have been called.

Module provides a QMock class that implements the API for setting up the mocks and also the magic method `methodGate` that is called for every method which is not explicitly defined. This is removing the need of stubbing all the methods one by one. After performing an action, you can make assertions about which methods were called and arguments they were called with.

## License

The source code is released under the LGPL 2.1 and MIT licenses; either license may be used at the user's discretion.  Note that both licenses are treated equally by the Qore library in the sense that both licenses allow the module to be loaded without restrictions by the Qore library (even when the Qore library is initialized in GPL mode). See COPYING.MIT and COPYING.LGPL for details on the open-source licenses.

## Documentation

See the @TODO link.
