#!/usr/bin/env qore
# -*- mode: qore; indent-tabs-mode: nil -*-

%new-style
%require-types
%enable-all-warnings
%strict-args

namespace QMock {

class QMockProxy {
    private {
        list<code> rules();
        *auto return_value;

        list<QMockProxy> others();

        bool strict;
    }

    public constructor(bool strict) {
        self.strict = strict;
    }

    public QMockProxy argEq(int arg_no, auto expected) {
        push self.rules, bool sub(*list argv) {
            if (!exists argv[arg_no]) {
                return False;
            }
            return argv[arg_no] === expected;
        };
        return self;
    }

    public nothing return_value(auto return_value) {
        self.return_value = return_value;
    }


    public nothing addEvaluation(QMockProxy obj) {
        push self.others, obj;
    }

    public auto eval(string method_name, *list argv) {
        bool match = True;
        foreach code rule in (self.rules) {
            if (!rule(argv)) {
                match = False;
                break;
            }
        }
        if (match) {
            return self.return_value;
        }

        foreach QMockProxy obj in (self.others) {
            try {
                return obj.eval(method_name, argv);
            } catch (ex) {
                switch (ex) {
                    case "QMOCK-EVAL-FAIL":
                        # ignore, try next one
                    break;
                    default:
                        rethrow;
                }
            }
        }

        if (self.strict === QMock::STRICT) {
            throw "QMOCK-EVAL-FAIL", sprintf("Mocked '%s' method evaluation failed", method_name);
        }
        return NOTHING;
    }
}

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

    public QMockProxy _mock(softlist<string> method_names) {
        auto obj = new QMockProxy(self.strict);
        foreach string method_name in (method_names) {
            if (exists self.configuration{method_name}) {
                auto mth = self.configuration{method_name};
                if (mth instanceof QMockProxy) {
                    mth.addEvaluation(obj);
                } else {
                    throw "INVALID-ARGUMENT", sprintf("Method %n is already mocked", method_name);
                }
            } else {
                self.configuration{method_name} = obj;
            }
        }
        return obj;
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
        auto mth = self.configuration{method_name};
        if (mth instanceof QMockProxy) {
            return mth.eval(method_name, argv);
        }
        return mth(argv);
    }
}

} # namespace
