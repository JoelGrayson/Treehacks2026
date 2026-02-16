# TORQ: Self-Driving Car for the 2026 TreeHacks Hackathon

This repo is for the ridesharing app, which lets you order a car to an address from a pickup location. It sends this information to the Jetson Thor in the car, so the car can drive over to pick you up and drive you to your destination.

When somebody who has TORQ installed in their car doesn't need their car (at night, when they're at work, or when they're away traveling), they could let their car do ridesharing for other people. Other people would request their car through this app.

YouTube demo: [https://youtu.be/zEDVGfCVhaw](https://youtu.be/zEDVGfCVhaw)


### Car-App Communication
* Jetson Thor ←MQTT→ VPS (MQTT broker) ←MQTT→ iPhone app
* Topics
  * from-phone/command-car to order the car (JSON payload is pickup location and destination coordinates)
  * from-car/gps-info - GPS info of where the car is

