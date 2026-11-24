"""Open WebUI tool: TARDIS morning brief, agenda, calendar, and voice."""
from __future__ import annotations

import subprocess
from pydantic import Field


CLI = "/home/doctor/.local/bin/morning-brief"
VOICE = "/home/doctor/.local/bin/tardis-voice"


def _run(args: list[str]) -> str:
    try:
        result = subprocess.run(
            args, capture_output=True, text=True, timeout=180, check=False
        )
    except Exception as exc:
        return f"Error: {exc}"
    out = (result.stdout or "").strip()
    err = (result.stderr or "").strip()
    if result.returncode != 0:
        return f"Error: {err or out or 'command failed'}"
    return out or "Done."


class Tools:
    def __init__(self):
        pass

    def get_morning_brief_data(
        self,
        days: int = Field(7, description="How many days of agenda items to include."),
    ) -> str:
        """Get raw weather, news, appointments and reminders for the morning brief.

        Returns JSON. Use this when the user asks for a morning brief, news,
        weather, today's schedule, or what is coming up. Then write the brief
        yourself in your TARDIS voice.
        """
        return _run([CLI, "collect", "--days", str(days)])

    def add_appointment(
        self,
        text: str = Field(..., description="The appointment description."),
        due: str = Field(..., description="Date/time, e.g. 'tomorrow 2pm' or '2026-11-25T14:00'."),
        tags: str = Field("", description="Optional comma-separated tags."),
    ) -> str:
        """Create a calendar appointment. Use this whenever the user asks to schedule, book, or create an appointment."""
        args = [CLI, "add", text, "--kind", "appointment", "--due", due]
        if tags:
            args += ["--tag", tags]
        return _run(args)

    def add_reminder(
        self,
        text: str = Field(..., description="What to remember."),
        due: str = Field("", description="Optional date/time, e.g. 'in 30m' or 'tomorrow 9am'."),
        tags: str = Field("", description="Optional comma-separated tags."),
    ) -> str:
        """Create a reminder. Use this when the user asks to be reminded about something."""
        args = [CLI, "add", text, "--kind", "reminder"]
        if due:
            args += ["--due", due]
        if tags:
            args += ["--tag", tags]
        return _run(args)

    def list_agenda(
        self,
        days: int = Field(7, description="How many days ahead to list."),
        kind: str = Field("", description="Optional filter: appointment or reminder."),
    ) -> str:
        """List upcoming appointments and reminders from the local calendar."""
        args = [CLI, "list", "--days", str(days)]
        if kind in ("appointment", "reminder"):
            args += ["--kind", kind]
        return _run(args)

    def complete_item(
        self,
        id: str = Field(..., description="The item ID, or the first characters of it."),
    ) -> str:
        """Mark an appointment or reminder as done."""
        return _run([CLI, "done", id])

    def snooze_item(
        self,
        id: str = Field(..., description="The item ID, or the first characters of it."),
        when: str = Field(..., description="New time, e.g. '30m', '2h', or 'tomorrow 9am'."),
    ) -> str:
        """Move an appointment or reminder to a new time."""
        return _run([CLI, "snooze", id, when])

    def delete_item(
        self,
        id: str = Field(..., description="The item ID, or the first characters of it."),
    ) -> str:
        """Delete an appointment or reminder."""
        return _run([CLI, "remove", id])

    def speak(
        self,
        text: str = Field(..., description="The text to speak aloud on the local machine."),
    ) -> str:
        """Speak text aloud with the local TARDIS voice. Use when the user asks you to say or read something."""
        return _run([VOICE, text])
