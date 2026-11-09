import multi_session_registration_py

sessions = [
    "/data/pin-slam/output_hdmapping-PIN-SLAM/session.json",
    "/data/optimized-sc-f-loam/output_hdmapping-optimized-sc-f-loam/session.json"
]

result = multi_session_registration_py.run(sessions)

print(result)
