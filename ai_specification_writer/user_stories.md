# ChatGPT
## Epic 1: Ride Discovery and Matching

### User Story 1: Search for Available Rides
As a passenger, I want to search for rides by entering my pickup location, destination, and departure time so that I can find a suitable commute.

Acceptance Criteria:
- Passenger can enter pickup and destination locations.
- Passenger can specify a departure time or indicate that they want to leave immediately.
- System displays available rides matching the requested route and time.
- Each result displays the driver's estimated departure time, available seats, estimated journey duration, and passenger contribution.
- Passenger can filter results by departure time, price, and detour duration.
Priority: MVP

### User Story 2: Find Nearby Drivers in Real Time
As a passenger, I want to see nearby drivers travelling in my direction so that I can find a convenient ride quickly.

Acceptance Criteria:
- System identifies available drivers whose routes are compatible with the passenger's journey.
- System considers pickup distance, destination proximity, departure time, and available seats when matching rides.
- System displays matching rides with estimated pickup times and locations.
- Ride availability updates when drivers accept bookings, cancel rides, or change their availability.
- System indicates when no suitable rides are available.
Priority: MVP

### User Story 3: Offer a Ride
As a driver, I want to publish my planned commute so that passengers travelling in the same direction can join my ride.

Acceptance Criteria:
- Driver can enter their pickup location, destination, departure time, and available seats.
- Driver can specify acceptable pickup and drop-off detours.
- Driver can set a proposed passenger contribution within platform-defined limits.
- System validates the ride details before publishing.
- Driver can view, edit, or cancel a published ride, subject to booking restrictions.
Priority: MVP

### User Story 4: Book a Ride
As a passenger, I want to reserve a seat on a suitable ride so that I can secure transport for my commute.

Acceptance Criteria:
- Passenger can review ride details and the estimated cost before booking.
- System prevents bookings when no seats are available.
- System confirms the booking immediately if the ride supports automatic booking.
- If driver approval is required, the passenger can view the booking status.
- Both driver and passenger receive a booking confirmation.
- System updates the remaining seat count after a booking is confirmed.
Priority: MVP

### User Story 5: Manage Ride Availability
As a driver, I want to manage my availability and upcoming rides so that I can coordinate my commute around changing circumstances.

Acceptance Criteria:
- Driver can view upcoming and completed rides.
- Driver can update departure times and ride details, with affected passengers notified of material changes.
- Driver can cancel a ride and provide a reason.
- System notifies passengers of cancellations and identifies alternative available rides where possible.
- System prevents changes that would conflict with confirmed bookings unless the affected passengers are appropriately notified.
Priority: MVP

## Epic 2: Payments and Cost Sharing

### User Story 6: View Ride Costs
As a passenger, I want to see the cost of a ride before booking so that I can decide whether it fits my budget.

Acceptance Criteria:
- System displays the total passenger contribution before booking.
- System clearly identifies any applicable service fees.
- System shows how the contribution is calculated, where applicable.
- Passenger must confirm the displayed price before committing to a paid booking.
- The agreed price is retained with the booking unless the passenger explicitly agrees to a change.
Priority: MVP

### User Story 7: Pay for a Ride
As a passenger, I want to pay for my ride through the platform so that I can complete the transaction conveniently and securely.

Acceptance Criteria:
- Passenger can add or select a supported payment method.
- System processes payments through an integrated payment provider.
- Passenger receives confirmation of successful payment.
- Failed payments are clearly communicated, and the passenger can retry.
- Payment status is visible in the booking details.
- Sensitive payment information is handled according to applicable security requirements.
Priority: MVP

### User Story 8: Receive Ride Contributions
As a driver, I want to receive passenger contributions for completed rides so that I can recover part of my commuting expenses.

Acceptance Criteria:
- Driver can view contributions associated with completed rides.
- System records payment amounts, transaction status, and applicable fees.
- Driver can view pending and completed payouts.
- System communicates payout failures or delays to the driver.
- Contributions and fees comply with applicable cost-sharing and transport regulations.
Priority: MVP

### User Story 9: View Payment History
As a passenger or driver, I want to view my transaction history so that I can track my commuting expenses and contributions.

Acceptance Criteria:
- User can view past transactions and associated rides.
- Each transaction displays the date, amount, payment status, and relevant ride details.
- User can access a receipt for completed transactions.
- User can filter transactions by date and status.
- System distinguishes refunds, failed payments, and completed payments.
Priority: Should Have

## Epic 3: Trust, Safety, and Reputation

### User Story 10: Rate a Ride Participant
As a passenger or driver, I want to rate the other participant after a completed ride so that I can help build trust within the community.

Acceptance Criteria:
- Only users associated with a completed ride can submit a rating.
- Ratings use a defined scale, such as one to five stars.
- Users can optionally provide written feedback.
- Each eligible participant can submit one rating per ride.
- System prevents duplicate ratings and supports reporting inappropriate reviews.
- Ratings are associated with the relevant user profile.
Priority: MVP

### User Story 11: View User Ratings and Reviews
As a passenger, I want to view a driver's ratings and reviews before booking so that I can make an informed decision about whom to travel with.

Acceptance Criteria:
- Driver profiles display an average rating and the number of ratings received.
- Passengers can view eligible written reviews.
- System displays only reviews from completed rides.
- Review moderation and reporting mechanisms are available.
- Users can view relevant profile information before confirming a booking.
Priority: MVP

### User Story 12: Manage My Profile
As a driver or passenger, I want to create and manage my profile so that other users can learn basic information about me before sharing a ride.

Acceptance Criteria:
- User can add a display name, profile photo, and optional biography.
- Driver can provide required vehicle details, including make, model, and registration information where legally required.
- System validates mandatory fields before allowing relevant activities.
- Users can update their profile information.
- Private information is not publicly exposed unless required for the service or explicitly shared for a booking.
Priority: MVP

### User Story 13: Report a Safety or Conduct Issue
As a passenger or driver, I want to report inappropriate behaviour or a safety concern so that the platform can investigate and take appropriate action.

Acceptance Criteria:
- User can report another participant or a specific ride.
- User can select a report category and provide supporting details.
- System confirms that the report has been submitted.
- Reports are available to authorised personnel for review.
- Users can access emergency guidance and appropriate emergency contact options.
- Sensitive report information is restricted to authorised personnel.
Priority: Should Have

## Epic 4: Eco-Impact Tracking

### User Story 14: Track My Environmental Impact
As a passenger, I want to see the estimated emissions I have saved by sharing rides so that I can understand the environmental benefits of my commuting choices.

Acceptance Criteria:
- System estimates emissions avoided for each eligible completed shared ride.
- Calculations use documented assumptions, including journey distance, vehicle emissions, and occupancy.
- User can view estimated emissions savings for an individual ride.
- System displays cumulative savings over a selected period.
- Estimates are labelled as approximate and distinguish actual measurements from calculated values.
Priority: MVP

### User Story 15: Track Environmental Impact as a Driver
As a driver, I want to see the estimated emissions savings associated with carrying passengers so that I can understand the environmental value of filling empty seats.

Acceptance Criteria:
- System estimates emissions avoided for eligible completed rides with passengers.
- Driver can view savings for individual rides and cumulative savings.
- Calculations use consistent assumptions across the platform.
- System avoids counting the same emissions savings multiple times across participants.
- Driver can view the methodology used to calculate the estimates.
Priority: Should Have

### User Story 16: View My Commuting Statistics
As a commuter, I want to view statistics about my shared journeys so that I can monitor my contribution to more efficient commuting.

Acceptance Criteria:
- Dashboard displays completed shared rides, total shared distance, and estimated emissions savings.
- Passengers can view estimated transport costs saved compared with a defined alternative.
- Drivers can view passenger contributions received.
- Statistics can be filtered by week, month, or year.
- The comparison baseline and calculation assumptions are clearly explained.
Priority: Should Have

## Epic 5: Notifications and Communication

### User Story 17: Receive Booking Notifications
As a passenger or driver, I want to receive notifications about booking events so that I can stay informed without constantly checking the application.

Acceptance Criteria:
- System notifies users when a booking is confirmed, rejected, or cancelled.
- System notifies users about material changes to a confirmed ride.
- Notifications include relevant ride details and a way to open the booking.
- Users can configure supported notification preferences.
- Notifications are delivered through enabled channels, such as push notifications or email.
Priority: MVP

### User Story 18: Communicate About a Ride
As a passenger or driver, I want to communicate with the other participant about pickup arrangements so that we can coordinate the journey.

Acceptance Criteria:
- Confirmed booking participants can exchange messages through the platform.
- Users can access the conversation from their booking details.
- The system provides notifications for new messages, subject to user preferences.
- Contact information remains private unless a user chooses to share it.
- Users can report abusive messages or block another user where supported.
Priority: Should Have

### User Story 19: Receive Ride Reminders
As a passenger, I want to receive reminders before my scheduled pickup so that I can arrive on time.

Acceptance Criteria:
- System sends a reminder at a configurable or predefined interval before departure.
- Reminder includes the scheduled pickup time and location.
- Passenger can access the booking directly from the reminder.
- Users are notified if the driver changes the pickup details.
- Cancelled bookings do not generate unnecessary reminders.
Priority: Should Have

## Epic 6: Account Management and Platform Reliability

### User Story 20: Register and Sign In
As a commuter, I want to register and securely sign in so that I can access personalised ride-sharing features.

Acceptance Criteria:
- Users can register using supported authentication methods.
- System validates required registration details.
- Users can securely sign in and sign out.
- Users can recover access to their accounts.
- System protects accounts against common authentication threats.
- Users must accept the applicable terms and privacy policy before using relevant services.
Priority: MVP

### User Story 21: Verify My Identity
As a passenger or driver, I want the platform to verify relevant identity information so that I can feel more confident sharing rides with other users.

Acceptance Criteria:
- System supports the verification checks required by the platform's safety policy and applicable laws.
- Verification status is displayed on the user's profile where appropriate.
- Users are informed about required verification steps and any failure.
- Sensitive verification information is protected and retained only as necessary.
- The platform distinguishes verified information from information that has not been checked.
Priority: Should Have

### User Story 22: Manage My Account and Privacy
As a commuter, I want to manage my account and privacy settings so that I can control how my personal information is used and shared.

Acceptance Criteria:
- User can update supported account and privacy preferences.
- User can review the personal information visible to other users.
- User can request account deletion through a documented process.
- System handles personal information according to applicable privacy requirements.
- Users are informed about information that must be retained for legal, financial, or safety reasons.
Priority: MVP