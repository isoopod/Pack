import os
import sys
import urllib.request
import logging
import json

from luau_execution_task import createTask, awaitTaskCompletion, getTaskLogs

ROBLOX_API_KEY = os.environ["ROBLOX_API_KEY"].strip()
ROBLOX_UNIVERSE_ID = os.environ["ROBLOX_UNIVERSE_ID"]
ROBLOX_PLACE_ID = os.environ["ROBLOX_PLACE_ID"]

def read_file(file_path):
    with open(file_path, "rb") as file:
        return file.read()


def upload_place(binary_path, universe_id, place_id, do_publish=False):
    print("Uploading place to Roblox")
    version_type = "Published" if do_publish else "Saved"
    request_headers = {
        "x-api-key": ROBLOX_API_KEY,
        "Content-Type": "application/xml",
        "Accept": "application/json",
    }

    url = f"https://apis.roblox.com/universes/v1/{universe_id}/places/{place_id}/versions?versionType={version_type}"

    buffer = read_file(binary_path)
    req = urllib.request.Request(
        url, data=buffer, headers=request_headers, method="POST"
    )

    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode("utf-8"))
        place_version = data.get("versionNumber")

        return place_version


def run_luau_task(universe_id, place_id, place_version, script_file):
    logging.info("Executing Luau task")
    script_contents = read_file(script_file).decode("utf8")

    attempt = 1
    while True:
        task = createTask(
            ROBLOX_API_KEY, script_contents, universe_id, place_id, place_version
        )

        data = awaitTaskCompletion(ROBLOX_API_KEY, task["path"], 60)
        if data is not None:

            logs = getTaskLogs(ROBLOX_API_KEY, data["path"])

            print(logs)

            match data["state"]:
                case "COMPLETE":
                    logging.info("Lua task completed successfully")
                    exit(0)
                case "FAILED":
                    logging.error("Lua task failed")
                    print(data["error"])
                    print("Luau task failed", file=sys.stderr)
                    exit(1)
                case "CANCELLED":
                    logging.error("Lua task cancelled")
                    exit(1)

        logging.warning(f"Task failed to resolve (stuck in PROCESSING) attempt {attempt}. Retrying...")
        attempt += 1


if __name__ == "__main__":
    universe_id = ROBLOX_UNIVERSE_ID
    place_id = ROBLOX_PLACE_ID
    binary_file = sys.argv[1]
    script_file = sys.argv[2]

    place_version = upload_place(binary_file, universe_id, place_id)
    run_luau_task(universe_id, place_id, place_version, script_file)
