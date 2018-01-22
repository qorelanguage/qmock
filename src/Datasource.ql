#!/usr/bin/env qore
# -*- mode: qore; indent-tabs-mode: nil -*-

%new-style
%require-types
%enable-all-warnings
%strict-args

%include "./QMock.ql"

namespace QMock {

class DatasourceMock inherits QMock, Qore::SQL::AbstractDatasource {
    *string getPassword() { return QMock::methodGate("getPassword"); }
    *string getOSEncoding() { return QMock::methodGate("getOSEncoding"); }
    *string getDBName() { return QMock::methodGate("getDBName"); }
    any selectRows(string sql) { return QMock::methodGate("selectRows", sql); }
    bool inTransaction() {  return QMock::methodGate("inTransaction"); }
    any getClientVersion() { return QMock::methodGate("getClientVersion"); }
    any exec(string sql) { return QMock::methodGate("exec", sql); }
    *int getPort() { return QMock::methodGate("getPort"); }
    any execRaw(string sql) { return QMock::methodGate("execRaw", sql); }
    any getServerVersion() { return QMock::methodGate("getServerVersion"); }
    *string getHostName() { return QMock::methodGate("getHostName"); }
    string getDriverName() { return QMock::methodGate("getDriverName"); }
    any select(string sql) { return QMock::methodGate("select", sql); }
    string getDBEncoding() { return QMock::methodGate("getDBEncoding"); }
    any vselect(string sql, *softlist vargs) { return QMock::methodGate("vselect", sql, vargs); }
    string getConfigString() { return QMock::methodGate("getConfigString"); }
    any vselectRows(string sql, *softlist vargs) { return QMock::methodGate("vselectRows", sql, vargs); }
    nothing beginTransaction() { QMock::methodGate("beginTransaction"); }
    nothing rollback() { QMock::methodGate("rollback"); }
    any selectRow(string sql) { return QMock::methodGate("selectRow", sql); }
    hash getConfigHash() { return QMock::methodGate("getConfigHash"); }
    nothing commit() { QMock::methodGate("commit"); }
    any vselectRow(string sql, *softlist vargs) { return QMock::methodGate("vselectRow", sql, vargs); }
    any vexec(string sql, *softlist vargs) { return QMock::methodGate("vexec", sql, vargs); }
    *string getUserName() { return QMock::methodGate("getUserName"); }
    AbstractSQLStatement getSQLStatement() { return QMock::methodGate("getSQLStatement"); }
}

} # namespace
