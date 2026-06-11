# Hutik sa Katagman

## An Archaeological Mystery Game Rooted in Philippine Heritage

**Genre:** Archaeological mystery / puzzle-adventure  
**Platform:** Windows  
**Audience:** Ages 14+, students, history enthusiasts, and cultural tourists  
**Setting:** A present-day museum and a reconstructed Katagman, Oton, Iloilo, during the late 14th to early 15th centuries  
**Tone:** Contemplative, culturally grounded, and intellectually engaging  
**Development stage:** Concept / pre-production

## Executive Summary

`Hutik sa Katagman` is a single-player puzzle-adventure in which a junior archaeologist catalogs material connected to the Oton Gold Death Mask. After discovering an overlooked gold Eye Piece, the protagonist experiences vivid archaeological reconstructions of ancient Katagman and investigates how its community lived, traded, crafted gold, and honored the dead.

The reconstruction is not literal time travel and does not claim to reproduce the past with certainty. It is an interpretation assembled from objects, excavation records, material evidence, and the limits of the archaeological record.

The game contains no combat. Progress comes through observation, listening, pattern recognition, and cultural reasoning. The player's ultimate objective is to recover the missing Nose Piece, restore the Oton Gold Death Mask record, and preserve an incomplete chapter of Iloilo's heritage without pretending that archaeology can answer every question.

The project is intended to work both as an entertainment experience and as a potential cultural-education tool for museums, classrooms, and digital tourism.

## Historical Foundation

The Oton Gold Death Mask was found in situ on June 5, 1967, during systematic excavations in San Antonio, Oton, Iloilo led by National Museum anthropologists Alfredo Evangelista and F. Landa Jocano. The National Museum dates it to the late 14th to early 15th century, within the Age of Trade.

The artifact consists of decorated gold eye and nose covers. The National Museum describes repoussé dots and curvilinear motifs and places the object within a wider tradition of funerary gold face coverings. Its exhibition material connects gold with burial practice and social status and notes that ceramics and other valued possessions could accompany burials.

The game uses this evidence as its foundation. More specific claims about trade origins, architecture, language, goldworking procedure, mortuary practice, and social organization require review by appropriate historians, archaeologists, cultural workers, and language consultants before they are presented as fact.

## Why This Story Matters

The game focuses on people whose lives are known primarily through archaeological evidence rather than written personal testimony. Pre-colonial Philippine settings grounded in material evidence are rare in games. `Hutik sa Katagman` treats artifacts as evidence of lives, communities, skills, beliefs, and relationships rather than as exotic collectibles.

## Story and Narrative

### Premise

During a museum documentation project, the protagonist discovers an overlooked gold Eye Piece among records connected to the Oton burial finds. Examining it initiates immersive reconstructions of ancient Katagman.

The visions repeatedly correspond with archaeological evidence, but the game never treats every reconstructed detail as confirmed history. Guided by these interpretations, the archaeologist investigates trade, craft, domestic life, and burial practice while searching for the missing Nose Piece.

### Thematic Core

- Archaeology is an act of listening to people whom written history did not record.
- Incomplete evidence conflicts with the human desire for complete stories.
- Heritage is a shared responsibility rather than merely a museum possession.
- Every reconstruction is an interpretation with limits.

### Open-Ended Resolution

After the Eye Piece and Nose Piece are reunited, the Digital Museum reconstruction appears complete. A previously unnoticed excavation annotation then resurfaces:

> Context incomplete. Associated element not recovered.

The reconstruction separates into conflicting interpretations. One suggests that the burial assemblage is complete, another suggests missing context or material, and another reveals nothing conclusive. The archive eventually reports:

> ARCHAEOLOGICAL RECORD STATUS: INCOMPLETE

The ending does not confirm a hidden third artifact. It leaves the player with the more honest possibility that the object may be known while its original context and meaning remain only partially understood.

## Artifact Structure

### The Eye Piece: The Witness

The Eye Piece is found in the present-day museum sequence. It represents seeing the past through material evidence. The player identifies it by solving catalog, pottery-classification, excavation-note, and damaged-field-sketch puzzles.

### The Nose Piece: The Breath

The Nose Piece is recovered inside the reconstructed Katagman sequence. It represents the human lives behind archaeological objects. The player reaches it by paying attention to cultural context rather than by fighting enemies or completing unrelated abstract challenges.

The Eye Piece and Nose Piece are narrative and gameplay framing for components of the Oton Gold Death Mask. Any claim that one component was historically lost or separately recovered is fictional and must be labeled as such in educational material.

## Gameplay Design

### Full-Game Loop

1. Explore the museum archive as a junior archaeologist.
2. Inspect records and solve catalog and excavation puzzles.
3. Correctly identify the Eye Piece.
4. Enter an evidence-based reconstruction of ancient Katagman.
5. Complete trade, craft, and burial-context investigations.
6. Follow Cultural Echoes and recover the Nose Piece.
7. Restore the Oton Gold Death Mask record in the Digital Museum.
8. Encounter the unresolved limits of the archaeological record.

### Hackathon Vertical Slice

The prototype implements a focused version of the reconstructed-Katagman search:

`Explore -> listen -> follow Cultural Echoes -> search objects -> reveal the Nose Piece -> recover it -> trigger the portal placeholder -> restart`

The museum puzzles, three full obstacle sequences, final Digital Museum, and open-ended ending remain part of the full-game roadmap rather than the initial prototype.

## Core Mechanics

### Top-Down Exploration

The player moves through a compact reconstructed Katagman settlement using `WASD` or the arrow keys. Vegetation, waterways, structures, workshops, furniture, and collision boundaries shape exploration.

### Random Artifact Location

At the beginning of each prototype round, the game randomly assigns the Nose Piece to one of six authored hiding spots. When multiple spots are available, the game avoids immediately repeating the previous location.

### Cultural Echo Clues

The game does not use objective arrows, map markers, or textual hot-and-cold messages. Audio becomes clearer and louder as the player approaches the selected hiding spot. Potential layers include:

- Natural ambience
- Goldsmithing, pottery, market, or settlement activity
- Restrained musical elements
- Historically and linguistically reviewed dialect or voice recordings

The final recordings will be supplied and reviewed separately. Neutral placeholder audio may be used during implementation.

### Environmental Searching

Some hiding spots display the Nose Piece in the environment, such as a worktable or pottery shelf. Other spots conceal it beneath or inside searchable objects, such as a woven sleeping mat, storage chest, or trading basket.

The player presses `E` to inspect an object. Empty searchable objects may still be opened, making careful listening more useful than checking every prop mechanically.

### Artifact Recovery

Once the Nose Piece is visible and the player is in range, the game displays:

> Press E to recover the Nose Piece.

Collection hides the artifact, stops the Cultural Echoes, completes the round, and prepares discovery data.

### Portal Unlock Placeholder

The prototype creates a dictionary containing:

```json
{
  "player_id": "Player_001",
  "artifact_name": "Oton Gold Death Mask",
  "artifact_component": "Nose Piece",
  "discovered_location": "<selected location>",
  "status": "found"
}
```

It then simulates the organizer integration:

> PORTAL UNLOCKED  
> Oton Gold Death Mask Collection Restored.  
> Waiting for organizer API integration.

No real backend or final Digital Museum is included in the prototype.

### Replayable Rounds

Restarting closes searchable objects, clears portal feedback, resets collection state, selects another hiding spot, and restarts the proximity audio system.

## Full-Game Obstacle Sequences

### Trade Route Puzzle

Players compare ceramics and other evidence to reconstruct possible exchange relationships during the Age of Trade. Final origin labels and trade-route claims require source citations and specialist review.

### Goldsmith's Workshop

Players study decorative patterns and the material logic of repoussé work. The interaction must distinguish documented features of the mask from a fictionalized teaching reconstruction.

### Burial Protocol Challenge

Players interpret clues and arrange burial goods within a reconstructed context. Because mortuary practice is culturally sensitive and evidence may be incomplete, this sequence requires archaeological and cultural review before production.

## Audio and Atmosphere

### Present-Day Museum

- Archive pages and drawers
- Pencil notes and camera shutters
- Museum audio guides
- Recorded interviews or approved educational narration

### Reconstructed Katagman

- Metalworking and craft activity
- Pottery handling
- Marketplace ambience
- Water and trading-vessel ambience
- Wind through reconstructed structures
- Carefully reviewed chants, speech, or dialect material

Audio is both atmosphere and navigation. It supports the central metaphor that understanding the past requires learning how to listen.

## Visual Direction

### Present-Day Museum

The museum is a warm, amber-lit working archive with wooden drawers, storage cases, field photographs, handwritten labels, and research materials. It should feel functional and tactile rather than like a polished exhibition hall.

### Reconstructed Katagman

The past uses warm earth tones, filtered light, dense foliage, waterways, open work areas, and atmospheric softness. Visual instability or incomplete edges may communicate that the world is a reconstruction, but the game avoids magical spectacle.

Architecture, clothing, tools, landscape, and object placement require reference gathering and historical review. Inspiration images guide mood, camera, and density only; their art and layouts must not be copied.

## Educational and Cultural Goals

Players should encounter carefully sourced material concerning:

- The 1967 Oton excavation and the artifact's importance
- Gold face coverings in funerary contexts
- Oton during the Age of Trade
- Craft specialization and decorative metalworking
- Archaeological approaches to burial evidence
- The limits of interpretation when records are incomplete

Every educational statement should be classified internally as documented fact, supported interpretation, fictional reconstruction, or unresolved question.

## Cultural Review Requirements

Before public release, the team should obtain review for:

- Historical claims and archaeological terminology
- Hiligaynon title, dialogue, pronunciation, and voice direction
- Mortuary content and portrayal of the dead
- Clothing, settlement architecture, tools, and environmental details
- Ceramic origins and trade-network claims
- Goldworking interactions and terminology
- Museum labels, citations, and accessibility

## Development Roadmap

| Phase | Timeline | Key Deliverables |
| --- | --- | --- |
| Pre-production | Months 1-3 | Complete GDD, art bible, prototype, source register, and consultant outreach |
| Production: Alpha | Months 4-9 | Museum sequence, three obstacle sequences, audio system, and core narrative |
| Production: Beta | Months 10-12 | Full game playable, cultural and educator review, accessibility pass, and QA |
| Polish and release | Months 13-15 | Localization, final validation, launch build, and museum-partner deployment |

## Prototype Documents

- [Prototype design](superpowers/specs/2026-06-11-echoes-of-katagman-prototype-design.md)
- [Godot implementation plan](superpowers/plans/2026-06-11-echoes-of-katagman-prototype.md)

These documents implement the hackathon vertical slice and defer the full-game systems described above.

## Primary Historical Source

- National Museum of the Philippines, [Oton Gold Death Mask Gallery](https://www.nationalmuseum.gov.ph/exhibitions/nm-western-visayas-regional-museum/oton-gold-death-mask-gallery/)

Additional peer-reviewed and locally reviewed sources are required during pre-production, especially for content beyond the artifact's basic excavation, dating, decoration, and funerary context.

## Closing Statement

The past is only partially recovered. That is not a failure of archaeology; it is one of its most honest findings.

`Hutik sa Katagman` offers the player an encounter with the past through objects, fragments, inference, and uncertainty. Its purpose is not to turn the Oton Gold Death Mask into a curiosity, but to treat it as evidence of lives fully lived and a heritage worth the effort of careful reconstruction.

The archive remains open. The Eye Piece does not deactivate.
