#!/usr/bin/env bash
# Tests automatizados de vpn_check.sh y tech_log.sh con respuestas simuladas (sin red).
# Ejecutar: bash integration/tests/test_scripts.sh
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
S="$ROOT/skill/openevidence-research/scripts"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok(){ echo "PASS $1"; pass=$((pass+1)); }
ko(){ echo "FAIL $1 :: $2"; fail=$((fail+1)); }
expect(){ # name expected_exit expected_stdout_prefix cmd...
  local n="$1" e="$2" p="$3"; shift 3
  out="$("$@" 2>&1)"; rc=$?
  [ "$rc" = "$e" ] && [[ "$out" == "$p"* ]] && ok "$n" || ko "$n" "rc=$rc out=$out"
}

echo '{"ip":"x","country_code":"US","protected": true}' > "$T/t.json"
echo '{"country_code":"ES","protected":false}'          > "$T/f.json"
echo 'not json'                                          > "$T/g.json"
echo '{"country_code":"fr","protected":true}'           > "$T/fr.json"
echo '{"protected":true}'                                > "$T/nc.json"

expect vpn_true    0 "protected=true country=US country_ok=true" env NORDVPN_INSIGHTS_URL="file://$T/t.json" bash "$S/vpn_check.sh"
expect vpn_false   1 "protected=false"           env NORDVPN_INSIGHTS_URL="file://$T/f.json" bash "$S/vpn_check.sh"
expect vpn_garbage 3 "protected=unknown"         env NORDVPN_INSIGHTS_URL="file://$T/g.json" bash "$S/vpn_check.sh"
expect vpn_noconn  3 "protected=unknown"         env NORDVPN_INSIGHTS_URL="file://$T/missing.json" bash "$S/vpn_check.sh"
expect vpn_wrong_country 4 "protected=true country=FR country_ok=false" env NORDVPN_INSIGHTS_URL="file://$T/fr.json" bash "$S/vpn_check.sh"
expect vpn_no_country    4 "protected=true country_ok=unknown"           env NORDVPN_INSIGHTS_URL="file://$T/nc.json" bash "$S/vpn_check.sh"
expect vpn_no_requirement 0 "protected=true country=FR"                  env OE_REQUIRED_COUNTRY= NORDVPN_INSIGHTS_URL="file://$T/fr.json" bash "$S/vpn_check.sh"
# La salida nunca debe incluir la IP
out="$(NORDVPN_INSIGHTS_URL="file://$T/t.json" bash "$S/vpn_check.sh")"; [[ "$out" != *'"ip"'* && "$out" != *"x "* ]] && ok vpn_no_ip || ko vpn_no_ip "$out"

expect log_ok        0 ""                         env OE_LOG_DIR="$T/log" bash "$S/tech_log.sh" vpn_status true
expect log_bad_event 2 "tech_log: evento"         env OE_LOG_DIR="$T/log" bash "$S/tech_log.sh" consulta x
expect log_clinical  2 "tech_log: resultado"      env OE_LOG_DIR="$T/log" bash "$S/tech_log.sh" oe_query "varón de 67 años"
lines=$(wc -l < "$T/log/tech.log" | tr -d ' '); [ "$lines" = 1 ] && ok log_only_valid || ko log_only_valid "lines=$lines"

echo "---- $pass passed, $fail failed"
[ "$fail" = 0 ]
