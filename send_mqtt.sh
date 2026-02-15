#!/bin/bash
# Send an MQTT command-car message to the broker

BROKER="34.134.81.0"
PORT=1883
USERNAME="mqtt_user"
PASSWORD="subha"
TOPIC="from-phone/command-car"

PAYLOAD='{"timestamp":1771161454.1520162,"pickup":{"longitude":-122.17590176790547,"latitude":37.42871908539299},"destination":{"name":"Tresidder","longitude":-122.17095100502956,"latitude":37.42469641302641}}'

mosquitto_pub \
  -h "$BROKER" \
  -p "$PORT" \
  -u "$USERNAME" \
  -P "$PASSWORD" \
  -t "$TOPIC" \
  -m "$PAYLOAD"

echo "Sent MQTT message to $TOPIC"
