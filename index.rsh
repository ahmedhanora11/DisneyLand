'reach 0.1';

const[gameResult, B_Won, Draw, A_Won] = makeEnum(3);

const winner = (handA, handB, gHandA, gHandB) => {

  if (gHandA == gHandB) {
    return Draw;
  }else {
    if (gHandA == (handA + handB)) {
      return A_Won;
    }else{
      if(gHandB == (handA + handB)) {
        return B_Won;
      }else{
        return Draw;
      }
    }
  }
};
//assert
assert(winner(0, 4, 0, 4) == B_Won);
assert(winner(4, 0, 4, 0) == A_Won);
assert(winner(0, 1, 0, 4) == Draw);
assert(winner(4, 4, 4, 4) == Draw);

forall(UInt, a =>
forall(UInt, b =>
forall(UInt, c =>
forall(UInt, d =>
assert(gameResult(winner(a, b, c, d)))))));

forall(UInt, a =>
forall(UInt, b =>
forall(UInt, c =>
assert(winner(a, b, c, c) == Draw))));

//data definition
const Shared = {
  ...hasRandom,
  getHand: Fun([], UInt),
  getGuess: Fun([], UInt),
  seeResult: Fun([UInt], Null),
  tellTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
  const Ahmed = Participant('Ahmed', {
    ...Shared,
    wager: UInt,
    deadline: UInt,
  });

  const Dolla = Participant('Dolla', {
    ...Shared,
    acceptWager: Fun([UInt], Null),
  });
  init();

  //the program

  const tellTimeout = () => {
    each([Ahmed, Dolla], () => {
      interact.tellTimeout();
    });
    };

    Ahmed.only(() => {
      const amt = declassify(interact.wager);
      const time = declassify(interact.deadline);
    });
  
  Ahmed.publish(amt, time)
    .pay(amt);
  commit();

  Dolla.interact.acceptWager(amt);
  Dolla.pay(amt)
  .timeout(relativeTime(time), () => closeTo(Ahmed, tellTimeout));
  
  var result = Draw;
  invariant(balance() == 2 * amt && gameResult(result));
  
  while(result == Draw){
    commit();
  


  Ahmed.only(() => {
    const _handA = interact.getHand();
    const _gHandA = interact.getGuess();

    const [_commitA, _saltA] = makeCommitment(interact, _handA);
    const commitA = declassify(_commitA);
    
    const [_gCommitA, _gSaltA] = makeCommitment(interact, _gHandA);
    const gCommitA = declassify(_gCommitA);
  });
  
  Ahmed.publish(commitA, gCommitA)
  .timeout(relativeTime(time), () => closeTo(Dolla, tellTimeout));
  commit();

  unknowable(Dolla, Ahmed(_handA, _saltA));
  unknowable(Dolla, Ahmed(_gHandA, _gSaltA));

  Dolla.only(() => {
    const _handB = interact.getHand();
    const _gHandB = interact.getGuess();
    const handB = declassify(_handB);
    const gHandB = declassify(_gHandB);
  });

  Dolla.publish(handB, gHandB)
  .timeout(relativeTime(time), () => closeTo(Ahmed, tellTimeout));
  commit();

  Ahmed.only(() => {
    const [saltA, handA] = declassify([_saltA, _handA]);
    const [gSaltA, gHandA] = declassify([_gSaltA, _gHandA]);
  })

  Ahmed.publish(saltA, handA, gSaltA, gHandA)
  .timeout(relativeTime(time), () => closeTo(Dolla, tellTimeout));
  
  checkCommitment(commitA, saltA, handA);
  checkCommitment(gCommitA, gSaltA, gHandA);

  //require continue and to update the variables

  result = winner(handA, handB, gHandA, gHandB);
  continue;
}
//while ended here

assert(result == A_Won || result == B_Won);
transfer(2 * amt).to(result == A_Won ? Ahmed : Dolla);
commit();

each([Ahmed, Dolla], () => {
  interact.seeResult(result);
});

exit();

});



