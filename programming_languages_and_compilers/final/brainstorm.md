# Brainstorming for final project
## Inspiration
I think counterpoint is probably a regular language. This means I could write a grammar for it, assign tokens to the non-terminals, and create a language where if you write something, it must be counterpoint. This is fun but not entirely practical. How can I instead write a programming language about music?

If I write a language that compiles to Lilypond and/or MIDI, then I can write programs that compile to songs. The output could be whatever is printed, and the structures could be based on musical things.


## Scratchpad Ideas
Should primitives be types of notes, articulations, rhythms, pitches, beats?

### Articulations:

```
staccato initial = C // creates a staccato note coerced from the literal value C
legato second, third; // creates uninitialized legato notes
measure meas = 4; // numbers are number of beats?

for beat in meas {
	beat = D;
}

```
I don't like this idea. What about the following primitives:
* note
* measure
* phrase
* section
* piece

? 

```
note initial = c'4; // c fifth octave quarter note
note second = des2; // d flat fourth octave half note
measure m1 = initial + second; // adding two notes gives you a measure
m1 = m1 + c4; // adding a note to a measure returns a measure

phrase motif = m1 * 3; // multiple measures is a phrase
section A = motif + motif; // multiple phrases is a section

piece myPiece = section A * 2; // multiple sections make a piece
```

I would probably want to be able to coerce things into a higher level.

```
piece myPiece = c4; // an entire piece containing just a quarter note,
                    // the intermediate measure/phrase/section instantiations
                    // would be implicit
```

This would make a piece that contains a bunch of empty measures with a C on the third beat:
```
piece myPiece;
for (0..20) {
	measure m = r4 + r4 + c4 + r4;
	myPiece = myPiece + m;
}
```

This would make a piece that contains a bunch of empty measures with a C on the third beat:
```
piece myPiece;
for (0..20) {
        measure m = r4 + r4 + c4 + r4;
        myPiece = myPiece + m;
}
```

So now, this is a simple imperative language tweaked for musical applications. That's fine, and it will take advantage of the familiar aspects of coding that most programmers have been exposed to before. It could probably be adopted and learned without much of a learning curve. But is it the best way forward, musically?

Let's see what a function that takes a note as the root and returns a major I V I progression would look like.

```
// In this usage, allowing chords like this, I cannot assume + would give me a note. Chord and note would
// have to be separate types but with similar function.
function TonicDominantTonic(root: note) : measure {
	note third = root + 4; // perhaps just numbers could be semitones? but it would be nice to have
                               // addition/subtraction of intervals that were sensitive to the key...hm...
	note fifth = root + 7;
	note I = <root, third, fifth>;
	
	note V = transpose(I, 7); // transpose the chord by 7 semitones. Would also be good to
                                  // be able to transpose by degree/key-sensitive again...hm..
	return I + V + I;
}
```

Revised to use chord primitive:
```
function TonicDominantTonic(root: note) : measure {
	note third = root + 4; 
	note fifth = root + 7;
	chord I = <root, third, fifth>;
	
	chord V = transpose(I, 7); 
	return I + V + I; // here a chord plus a chord would have to return a measure
}
```

I could also alias intervals like m7, M2, etc to their semitone literal counterparts.

I'd like "key sensitive" transposing, because then I could, for example, generate a section in a minor transposition of a major section. In fact, maybe the entire langauge should be structured around having a key and then intervals from that key. The actual key wouldn't be specified until the abstract piece/section/whatever is instantiated.


```
function TonicDominantTonic() : measure {
	return I + V + I;
}

```

I definitely need to differentiate + from something that actually combines things at the same rhythmic time. What operator should denote this operation?

```
<c e g> == c4 ? e4 ? g4;
```

This also seems to innately be addition. I'm thinking just enclosing in `< >` should be this operation.

```
chord x = <c, e, g>;
chord y = <d, f, a>;
chord stackedXY = <x, y>;
```

That could work.

Okay, so now:
### Using relative pitches and not instantiating until the last moment:
With this method, the literals would be: ` I II III IV V VI VII `
Maybe those should be used for chords, and `1 b2 2 b3 #3 b4 #5 6 7`, etc.,  should be used for notes. This would be powerful. 
I think a note should be allowed to move up or down based on the key unless it is pinned with an accidental. I think the natural note could be pinned with `n`. `n2` would always be a natural 2. In E major, `n2` would be G natural instead of G sharp. 

Well no, let's get rid of the idea of pinning a note to a pitch ever, because then we are consolidating two concepts. So, `n` can be natural, that's fine, but that means the actual true note. So in E lydian, the `n2` would be an F sharp, the `b2` would be F natural, and the `#2` would be F double sharp. 

#### Twinkle Twinkle Little Star in Relative Pitch Notation
```
// These are phrases because they're collections of measures, but im coercing them into sections
section melody = segregate(4, 
	        1q 1q 5q 5q
                6q 6q 5h
                4q 4q 3q 3q
                2q 2q 1h);

section harmony = segregate(4,
		Iw
		IVw
		Vw
		Iw);
		
```

Here, I introduce a segregate function which takes a series of notes and segregates it into multiple measures instead of just putting them all into one. I also hypothesize the usage of space instead of + for sequential note placement. 

Using numbers and scale degrees eliminatese the possibility of having semitone literals, so I think the major/minor mapping (e.g. `m3`) for that would work. There are some kinks I'd need to iron out in the chord syntax, allowing for things like 7, 9, etc chords. I also need to sort out "pinning" a chord, if I want to enforce major or minor, etc. Perhaps just adding an m or M. And octave stuff. 

People could write libraries for chords with their preferred syntax and import them? 

Why use mathematical function application at all?

```
section melody
```
But now, if something is wri
