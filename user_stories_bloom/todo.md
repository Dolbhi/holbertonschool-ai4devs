## Project Management
Frontend: React
	Crystal
	Toni
Backend: Python
	Michael
	Bevan
API: 
Hosting: 

google maps
authentication

project management app

Task management

## Task Response:
Plant Tracking Mobile App: Task List

**Stack:** React Native (Expo) for the mobile app, Python (FastAPI) for the backend, PostgreSQL with PostGIS for spatial data, and S3-compatible storage for images.

I’ve read “Bevan’s hayfever warnings” as hay fever (pollen) warnings. Tell me if you meant something else.

### 1. Planning and Discovery

- Define target users (gardeners, hay fever sufferers, botanists, casual walkers) and their core jobs
- Write user stories and acceptance criteria for each feature
- Decide the MVP scope and what goes into later phases
- Choose the target platforms (iOS, Android, or both)
- Research data sources for bloom timing, weather, and pollen counts (e.g., Australian BOM, pollen APIs)
- Review legal requirements for location data, user-generated content, and privacy (e.g., GDPR, Australian Privacy Act)
- Set up project management, repositories, and a branching strategy

### 2. Design

- Create user flows for submission, browsing, filtering, and moderation
- Design wireframes and high-fidelity mockups
- Define the design system (colours, typography, components)
- Design the database schema: users, plants, submissions, photos, locations, bloom windows, reviews, flags
- Design the API contract (OpenAPI spec)
- Plan the moderation workflow and reputation rules

### 3. Backend Setup (Python)

- Set up the FastAPI project structure with environments (dev, staging, prod)
- Provision PostgreSQL with the PostGIS extension
- Configure object storage for photos
- Set up database migrations (Alembic)
- Implement configuration, logging, and error handling
- Set up authentication libraries (e.g., passlib for hashing, PyJWT for tokens)
- Set up background job processing (e.g., Celery or RQ) for image processing and predictions

### 4. Frontend Setup (React Native)

- Initialise the Expo project with TypeScript
- Set up navigation (e.g., React Navigation)
- Set up state management and API client (e.g., TanStack Query)
- Build the shared component library based on the design system
- Configure secure token storage
- Set up maps (e.g., react-native-maps or Mapbox)

### 5. User Accounts

- **Backend:** Build registration with email and password, including validation and hashed passwords
- **Backend:** Build login, logout, and JWT access and refresh tokens
- **Backend:** Build email verification and password reset flows
- **Backend:** Add rate limiting on auth endpoints
- **Frontend:** Build sign-up, login, and forgot-password screens
- **Frontend:** Build the profile screen and account settings
- **Both:** Write tests for the auth flows

### 6. Plant Submission

- **Backend:** Build a submission endpoint accepting one image, plant name, location, blooming window, and description
- **Backend:** Validate image type, size, and dimensions, and strip EXIF metadata for privacy
- **Backend:** Generate thumbnails and resized versions
- **Backend:** Store coordinates as PostGIS geography points
- **Backend:** Add a fuzzing option that reduces location precision for privacy
- **Frontend:** Build a camera or photo-picker screen with a preview
- **Frontend:** Request GPS permission and let users adjust or drop a pin manually
- **Frontend:** Build a form for the plant name, blooming window (start and end dates or months), and description
- **Frontend:** Show submission status and handle offline submission with a retry queue
- **Both:** Write tests for validation and upload edge cases

### 7. Plant Details

- **Backend:** Create a plant record that aggregates details from one or more submissions
- **Backend:** Define merge rules for conflicting submissions (e.g., name variants, differing bloom windows)
- **Backend:** Build an endpoint for the plant detail view with contributor counts and confidence scores
- **Frontend:** Build the plant detail screen with photo gallery, description, bloom window, and map preview
- **Frontend:** Show the source and date of details from each submission
- **Frontend:** Support suggesting edits to existing plant details

### 8. Temporal Representation

- **Backend:** Model blooming windows per plant and per region
- **Backend:** Build a bloom prediction service using historical submissions and, if available, weather or temperature data
- **Backend:** Build a pollen and hay fever warning service, pulling forecast data from a provider and mapping it to plants that cause allergies
- **Backend:** Schedule regular updates for predictions and warnings
- **Frontend:** Build a seasonal calendar or timeline view showing when plants bloom
- **Frontend:** Show bloom predictions with confidence levels
- **Frontend:** Build a hay fever warning banner and an alert screen, with push notifications for high-risk days
- **Both:** Validate predictions against known bloom observations and track accuracy over time

### 9. Spatial Representation

- **Backend:** Build geospatial queries (nearby plants, plants within a bounding box or radius) using PostGIS
- **Backend:** Build a map tile or clustering strategy for large datasets
- **Backend:** Add filters for plant attributes, bloom status, season, and distance
- **Frontend:** Build a map view with plant markers and clustering
- **Frontend:** Build a list view synced with the map
- **Frontend:** Build a filter panel (plant type, bloom status, season, distance, allergy risk)
- **Frontend:** Handle location permission denial gracefully

### 10. Community Moderation

- **Backend:** Build a review system where community members approve, reject, or request changes to submissions (PR-style)
- **Backend:** Implement review states (draft, pending, changes requested, approved, rejected) and history
- **Backend:** Build reviewer eligibility based on contribution history and reputation
- **Backend:** Build a reputation system with weighted votes and decay rules
- **Backend:** Implement spam detection: rate limits, duplicate image detection (perceptual hashing), and content classifiers
- **Backend:** Build a flagging and reporting system with a moderator queue
- **Backend:** Add audit logs for all moderation actions
- **Backend:** Implement sanctions: warnings, temporary suspensions, and bans
- **Frontend:** Build a review queue screen with diffs showing proposed changes
- **Frontend:** Build review actions with comments
- **Frontend:** Build a report button and contributor profile pages with contribution history
- **Frontend:** Build a moderator dashboard (web or mobile)
- **Both:** Write tests for review flows, reputation calculations, and spam detection

### 11. Notifications and Engagement

- Set up push notifications (Expo Notifications or FCM/APNs)
- Notify users when their submission is reviewed
- Send hay fever and bloom alerts based on user location and preferences
- Build notification preferences

### 12. Testing and Quality

- Write unit tests for backend services (pytest)
- Write API integration tests
- Write component tests for React Native (Jest and React Native Testing Library)
- Write end-to-end tests for critical flows (Detox or Maestro)
- Run load tests on search and map endpoints
- Run a security review: OWASP checks, dependency scanning, and permission audits
- Run usability testing with real users

### 13. Deployment and DevOps

- Containerise the backend with Docker
- Set up CI/CD (e.g., GitHub Actions) for linting, tests, and builds
- Deploy the backend to a cloud provider with managed PostgreSQL and object storage
- Set up monitoring, logging, and error tracking (e.g., Sentry)
- Configure backups and disaster recovery
- Set up EAS Build and Submit for iOS and Android releases

### 14. Launch and Operations

- Prepare app store listings, screenshots, and privacy disclosures
- Run a closed beta and collect feedback
- Create moderation guidelines and a community code of conduct
- Set up support channels and a help centre
- Monitor analytics for retention, submission quality, and moderation load
- Plan post-launch iterations based on feedback and data



make multiple user stories + features from stories
do yourself then do ai
do 2 personas

User accounts
- email/pwd
Plant submission
- 1 picture
- plant name
- location (GPS?)
- blooming window
- description
plant details
- details from submissions
Temporal representation
- bloom predictions
- seasons
- Bevan's hayfever warnings
spatial representation
- plant filtering
Community Moderation
- PR like reviews
- contributor/spam integrity

## User Story x5(self) + filtered AI add-on (up to 10)
As a [],
I want [],
So that []

## Persona 1
Sharon, 60, Office Worker
Background
- Grows plants at home
- Live in tropical Singapore with many trees
Goals
- Wants to take photo of blooming trees
- Wants to know when trees bloom
Difficulties
- Currently takes note of flowering trees during drives
- Returns to take photos
- No way to know when trees will flower
- Limited knowledge on types of trees

**Story 1**
As a user, I want to know when my favourite flowers are in bloom and for how long, so that I know when to go see them.
Feature: Save plants to a list + notification system
**Story 2**
As a user, I want to know how recent weather can affect blooming, so that the bloom time can be updated accurately.
Feature: Revised bloom prediction based on current weather
**Story 3**
As a user, I want to know where to find more of my favourite flowers, so that I can see more of them.
Feature: Enable searching via plant species
**Story 4**
As a contributor, I want let others know where flowering plants are, so that more attention can be brought to it.
Feature: Plant submission
**Story 5**
As a contributor, I want to report if a plant is currently blooming, so that list of currently blooming plants is accurate.
Feature: Plant update submission

**Story 6**
As a user, I want to see a calendar of upcoming blooms, so that I can schedule outings around them.
Feature: Calendar of upcoming blooms of saved plants
**Story 7**
As a user, I want to view blooming trees displayed on an interactive map, so that I can plan an efficient route to visit multiple flowering sites in one trip.
Feature: Bloom map filtered by blooming state
**Story 8**
As a contributor, I want to correct wrong tree names or locations, so that information stays reliable.
Feature: Correction submission
**Story 9**
As a contributor, I want to see how many people viewed or benefited from my reports, so that I feel motivated to keep contributing.
Feature: Submission feedback
**Story 10**
As a user, I want to share a bloom location with friends or family, so that I can invite them to join me.
Feature: Sharing option on plants
## Persona 2
Dave, 20, Uni Student
Background
- Recreational photography
- Full time student
Goals
- Practice close-up photography
- Photos for social media
Difficulties
- Do not know what flowers a tree will have in advance
- No idea when plants will flower

**Story 1**
As a user, I want to view photos other people have taken of a tree, so that I can get ideas for angles and composition.
Feature: Photo gallery with timestamps for each plant
**Story 2**
As a user, I want to know the identity of a flower I saw, so that I can learn more about it.
Feature: Information page identifying plants
**Story 3**
As a user, I want to accurately know when flowers are in bloom, so that I not waste time checking in person.
Feature: Bloom prediction
**Story 4**
As a user, I want to find new flowering plants, so that I can photograph different things.
Feature: Flower search by currently blooming
**Story 5**
As a user, I want to know when the flower I saw will flower again, so that I know when to return to it.
Feature: Bloom prediction

**Story 6**
As a user, I want to know if a tree is on private or restricted land, so that I do not waste a trip or trespass.
Feature: Private land indicator/restriction indication
**Story 7**
As a user, I want to browse flowering trees by colour, so that I can find ones that match what I like to photograph.
Feature: Search by colour
**Story 8**
As a user, I want to learn basic facts about each tree species (e.g. common name, origin, flowering season), so that I can build up my knowledge over time.
Feature: Plant details
**Story 9**
As a user, I want to see the typical flowering season for each tree, so that I can plan photography trips throughout the year.
Feature: Upcoming blooms
**Story 10**
As a user, I want to save trees to a favourites list, so that I can easily return to them later.
Feature: Favourites list