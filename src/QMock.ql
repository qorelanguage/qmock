#!/usr/bin/env qore
# -*- mode: qore; indent-tabs-mode: nil -*-

%new-style
%require-types
%enable-all-warnings
%strict-args

namespace QMock {

class QMock {
    private {
        hash configuration;
        bool strict;
    }

    public {
        const STRICT = True;
        const VAGUE = False;
    }

    public {
        list _mock_calls;
        hash _mock_calls_with_args;
    }

    public constructor(bool strict = QMock::STRICT) {
        self._mock_settings(strict);
    }

    # settings
    public nothing _mock_settings(bool strict) {
        self.strict = strict;
    }

    public nothing _mock(softlist<string> method_names, code method_code) {
        foreach string method_name in (method_names) {
            if (exists self.configuration{method_name}) {
                throw "INVALID-ARGUMENT", sprintf("Method %n is already mocked", method_name);
            }
            self.configuration{method_name} = method_code;
        }
    }

    # asserts
    public int _assert_called(string method_name) {
        return elements select self._mock_calls, $1 === method_name;
    }

    public bool _assert_called_once(string method_name) {
        return 1 === self._assert_called(method_name);
    }

    public int _assert_called_with_args(string method_name, list args) {
        int amount_of_calls = 0;
        foreach list called_args in (\self._mock_calls_with_args{method_name}) {
            amount_of_calls += (called_args === args);
        }
        return amount_of_calls;
    }

    public bool _assert_called_once_with_args(string method_name, list args) {
        return self._assert_called_once(method_name) && self._assert_called_once_with_args(method_name, args);
    }

    # mock implementation
    private auto methodGate(string method_name) {
        # track call
        push _mock_calls, method_name;

        # track call with arguments
        if (!exists _mock_calls_with_args{method_name}) {
            _mock_calls_with_args{method_name} = ();
        }
        push _mock_calls_with_args{method_name}, argv;

        # look for mocked code
        if (!exists self.configuration{method_name}) {
            if (!exists self.configuration{"*"}) {
                if (self.strict === QMock::STRICT) {
                    throw "INVALID-ARGUMENT", sprintf("Method %n is not mocked", method_name);
                } else {
                    return NOTHING;
                }
            }
            method_name = "*";
        }

        # call mocked code
        return self.configuration{method_name}(argv);
    }
}

} # namespace
