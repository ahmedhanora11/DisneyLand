import { loadStdlib,ask } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

const isAhmed = await ask.ask(
  `Are you Ahmed?` , 
  ask.yesno
);
const who = isAhmed ? 'Ahmed' : 'Dolla';

console.log(`Starting Rock, Paper, Scissors! as ${who}`);

let acc = null;

const createAcc = await ask.ask(
  `Would you like to create an acconut? (only possible on divnet)`,
  ask.yesno
);

if(createAcc){
  acc = await stdlib.newTestAccount(stdlib.parseCurrency(1000));
} else {
  const secret = await ask.ask(
  `What is your account secret?`,
  (x => x));
  acc = await stdlib.newAccountFromSecret(secret);
}

let ctc = null;
if(isAhmed){
  ctc = acc.contract(backend);
  ctc.getInfo().then((info) => {
    console.log(`The contract is deployed as = ${JSON.stringify(info)}`);
  });
}else{
  const info = await ask.ask(
    `Please paste the contract information:`,
    JSON.parse
  );
  ctc = acc.contract(backend, info)
}

const fmt = (x) => stdlib.formatCurrency(x, 4);
const getBalance = async () => fmt(await stdlib.balanceOf(acc));

const before = await getBalance();
console.log (`Your balance is ${ before }`);

const interact = {...stdlib.hasRandom};

interact.tellTimeout = () => {
  console.log(`There was a timeout.`);
  process.exit(1);
};

if (isAhmed){
  const amt = await ask.ask (
    `How much do you want to wager?`,
    stdlib.parseCurrency
  );
  interact.wager = amt;
  interact.deadline = { ETH: 100, ALGO: 100, CFX: 1000 }[stdlib.connector];
}else{
  interact.acceptWager = async (amt) => {
    const accepted = await ask.ask(
      `Do you accept the wager of ${fmt(amt)}?`,
      ask.yesno
    );
    if(!accepted){
      process.exit(0);
    }
  };
}

const Hand = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five'];
const Hands = {
  'Zero': 0, 'zero':0, '0':0,
  'One': 1, 'one':1, '1':1,
  'Two': 2, 'two':2, '2':2,
  'Three': 3, 'three':3, '3':3,
  'Four': 4, 'four':4, '4':4,
  'Five': 5, 'five':5, '5':5,
};

interact.getHand = async () => {
  const hand = await ask.ask(`What finger will you play?`, (x) => {
    const hand = Hands[x];
    if(hand === undefined){
      throw Error(`not a valid finger ${hand}`);
    }
    return hand;
  });
  console.log(`You played ${Hand[hand]}`);
  return hand;
};


const Guess = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten'];
const Guesses = {
  'Zero': 0, 'zero':0, '0':0,
  'One': 1, 'one':1, '1':1,
  'Two': 2, 'two':2, '2':2,
  'Three': 3, 'three':3, '3':3,
  'Four': 4, 'four':4, '4':4,
  'Five': 5, 'five':5, '5':5,
  'Six': 6, 'six':6, '6':6,
  'Seven': 7, 'seven':7, '7':7,
  'Eight': 8, 'eight':8, '8':8,
  'Nine': 9, 'nine':9, '9':9,
  'Ten': 10, 'ten':10, '10':10,
};

interact.getGuess = async () => {
  const guess = await ask.ask(`What is your guess?`, (y) => {
    const guess = Guesses[y];
    if(guess === undefined){
      throw Error(`not a valid guess ${guess}`);
    }
    return guess;
  });
  console.log(`You Chose: ${Guess[guess]}`);
  return guess;
};


const Result = ['Dolla won', 'Draw', 'Ahmed Won'];
interact.seeResult = async (result) => {
  console.log(`The result is: ${Result[result]}`);
};

const part = isAhmed ? ctc.p.Ahmed : ctc.p.Dolla;
await part(interact);

const after = await getBalance();
console.log(`Your balance is now: ${after}`);

ask.done();

