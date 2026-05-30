# Conference Call (Add Participant) — Implementation Guide

## Overview

A caregiver in an active call can add another caregiver or a family member from the patient's care circle to the call. The invited person receives the same in-app popup that any incoming call triggers. Once they accept, they join the existing Chime meeting and their video tile appears automatically for all participants.

**Who can invite:** Caregiver only
**Who can be invited:** Any CAREGIVER or FAMILY_MEMBER with an active link to the patient in the call
**Who cannot be invited:** Another PATIENT
**Sentiment analysis:** Unchanged — patient sentiment only, same as 1:1 calls

---

## Architecture

```
Caregiver taps "Add Participant"
  → Flutter: GET /api/v3/calls/{callId}/eligible-invitees
  ← Backend: returns care-circle members not already in call

Caregiver selects a person
  → Flutter: POST /api/v3/calls/{callId}/invite  { targetUserId }
  ← Backend: createAttendee() on existing Chime meeting
           + WebSocket "incoming-video-call" (isConferenceInvite: true) → invitee

Invitee sees "Joining Existing Call" popup
  → accepts → Flutter: POST /api/v3/calls/{callId}/join  (existing endpoint, unchanged)
  ← Chime SDK: new video tile appears for all participants automatically
```

---

## Files Changed

### Backend

| File | Change |
|------|--------|
| [CallController.java](../../backend/core/src/main/java/com/careconnect/controller/CallController.java) | `GET /{callId}/eligible-invitees`, `POST /{callId}/invite`, `findPatientInCall()`, `getCallUserDisplayName()` helpers. `FamilyMemberService` autowired. |

No changes to `ChimeService`, `CallNotificationHandler`, or any data model — the existing `createAttendee()` and `sendNotificationToUser()` methods handle everything.

### Frontend

| File | Change |
|------|--------|
| [video_call_service.dart](../../frontend/lib/services/video_call_service.dart) | `getEligibleInvitees(callId)`, `inviteParticipant(callId, targetUserId)` |
| [call_notification_service.dart](../../frontend/lib/services/call_notification_service.dart) | Reads `isConferenceInvite` flag from incoming `incoming-video-call` WS message; passes it to `IncomingCallPopup` |
| [incoming_call_popup.dart](../../frontend/lib/widgets/incoming_call_popup.dart) | `isConferenceInvite` optional param; title changes to "Joining Existing Call", subtitle to "invited by Caregiver" |
| [hybrid_video_call_widget.dart](../../frontend/lib/widgets/hybrid_video_call_widget.dart) | `person_add` icon button in controls bar (caregiver-only); `_showAddParticipantDialog()`, `_inviteParticipant()` methods |
| [chime_meeting_embed_web.dart](../../frontend/lib/widgets/chime_meeting_embed_web.dart) | Dynamic multi-tile video grid (see section below) |

---

## API Reference

### GET `/api/v3/calls/{callId}/eligible-invitees`

**Auth:** JWT — CAREGIVER role required
**Returns:** Array of inviteable care-circle members

```json
[
  { "userId": 42, "name": "Dr. Patel", "role": "CAREGIVER", "relationship": null },
  { "userId": 87, "name": "Maria Santos", "role": "FAMILY_MEMBER", "relationship": "Daughter" }
]
```

**Errors:**
- `403` — caller is not a CAREGIVER
- `410` — meeting is no longer active
- `404` — no patient found in the call's telemetry

### POST `/api/v3/calls/{callId}/invite`

**Auth:** JWT — CAREGIVER role required
**Body:** `{ "targetUserId": 42 }`
**Returns:** `{ "status": "invited", "callId": "...", "targetUserId": 42 }`

**Errors:**
- `403` — caller is not a CAREGIVER, or target is a PATIENT, or target has no active link to this patient
- `410` — meeting is no longer active
- `404` — user not found / no patient in call

**Side effects:**
- Adds the target as a Chime attendee on the existing meeting
- Sends `incoming-video-call` WebSocket message with `isConferenceInvite: true` to the target if online
- Records a `CONFERENCE_INVITE` telemetry event

---

## Chime Video Grid

The previous layout used a single fixed `<video id="remoteVideo">` element (PiP local + one full-screen remote). The updated layout uses a dynamic CSS grid inside the iframe.

**CSS grid classes** (`#videoGrid.count-N`):

| Participants | Grid |
|---|---|
| 1 remote | 1 column, full screen |
| 2 remotes | 2 columns, 1 row |
| 3–4 remotes | 2×2 grid |

When a new participant joins, Chime SDK fires `videoTileDidUpdate`. The JS creates a new `<video class="remote-video">` element, appends it to `#videoGrid`, and updates the grid class. When a participant leaves, `videoTileWasRemoved` removes their element and updates the class. No Flutter-side changes are needed — Chime handles all the signaling.

---

## Known Limitations

### Offline invitees
If the target user does not have an active WebSocket session when `POST /invite` is called, the Chime attendee credential is still created (they are "in" the meeting at the Chime level), but no in-app notification is delivered. The caregiver sees a snackbar: *"[Name] is not available right now."*

**Future work:** The push notification infrastructure (`SnsService`, `DeviceToken`, `device_tokens` table) is fully built but not connected to call flows. Wiring `SnsService.sendPushNotification()` into `CallNotificationHandler.sendNotificationToUser()` as a fallback when the target has no open WebSocket session would fix this for both 1:1 calls and conference invites simultaneously. See the TODO comment in `CallNotificationHandler` around the `call-invitation-failed` path.

### End-call notification scope
The current `end-call` WebSocket message only notifies the original `otherPartyId`. If a third participant was added and the call initiator ends the call, only the original recipient gets the `call-ended` WS notification. The third participant's Chime session terminates at the AWS level (meeting is deleted), but their Flutter UI does not get the explicit WS notification. Their Chime embed will disconnect and surface `audioVideoDidStop`, which is a graceful failure, but no "Call ended by X" snackbar appears.

**Future work:** Track all participant IDs server-side (a `call_participants` table or in-memory set in `CallNotificationHandler`) and broadcast `call-ended` to all of them when the meeting ends.

### Maximum participants
AWS Chime SDK for Meetings supports up to 250 attendees. The CSS grid caps the visual layout at a 2×2 tile arrangement (4 tiles). A 5th+ participant's tile will render but may extend outside the visible area. For the current use case (1 patient + 2 caregivers/family) this is not an issue.

---

## Testing Checklist

- [ ] Caregiver in a 1:1 call sees the `person_add` button in the control bar
- [ ] Patient in a 1:1 call does NOT see the `person_add` button
- [ ] Tapping the button while call is loading shows a spinner, not a crash
- [ ] If no eligible invitees exist, a snackbar shows "No available care-circle members to add."
- [ ] Eligible list excludes users already in the call
- [ ] Eligible list excludes patients
- [ ] Selecting an online invitee: they receive "Joining Existing Call" popup
- [ ] Selecting an offline invitee: caregiver gets "not available" snackbar
- [ ] Accepted invitee joins Chime meeting and their video tile appears for all participants
- [ ] Grid shifts from 1-column to 2-column when second remote joins
- [ ] When a participant leaves, their tile is removed and grid re-adjusts
- [ ] Sentiment analysis continues on patient audio/video only — not on added caregivers/family
