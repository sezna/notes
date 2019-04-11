// TODO: externalize parser, create starter environment

if (process.argv.length > 2) {
	console.warn("More than one input file specified, using the first file...");
	console.warn(process.argv);
}
let inputFile = process.argv[2];

let inputText = "testing this is    input  text".replace(/\s+/g, " ");

let globalEnv = {};

// Remove duplicate whitespace.
let symbols = inputText.split(" ");

console.log(symbols);

const tokens = ["note", "+"]


const grammar = {
	note: ["name", "=", "val"]
	"+": 
}

const processors = {
	note: constructNoteStatement
}

function constructNoteStatement(name, value) {
	globalEnv[name] = value;
}

// Parse symbols
for (symbol in symbols) {
	let isToken = tokens.indexOf(symbol) > 0;
	
	if (isToken) {
		let rule = grammar[symbol];
		let num_syms = rule.length;
	}
	
	// If it isn't a token, it should be in the global environment.
	if (!isToken) {
		
		
	}
	
	// If it isn't a token, or in the environment, then it is a problem.
}
