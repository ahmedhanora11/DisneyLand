'reach 0.1';
'use strict';

const Details = Object({
    name: Bytes(128),
    receiptId: UInt,
    deadline: UInt,
    seller: Address,
});

export const main = Reach.App(() => {
    const Seller = Participant('Seller', {
        details: Details,
        payed: Bool,
    });
    const Customer = Participant('Customer', {
        details: Details,
        price: UInt,
        quantity: UInt,
        getReceipt: Fun([Contract], Null),
    });
    init();

    Customer.only(() => {
        const details = declassify(interact.details);
        const price = declassify(interact.price);
        const quantity = declassify(interact.quantity);
    });
    const total = price * quantity
    Customer.publish(details).pay(total);
    const { deadline, seller } = details;
    enforce(thisConsensusTime() < deadline, "too late");
    Customer.interact.getReceipt(getContract());
    commit();

    Seller.only(() => {
        const hdetails = declassify(interact.details);
        check(details == hdetails, "wrong event");
        const payed = declassify(interact.payed);
    });
    Seller.publish(payed)
    enforce(thisConsensusTime() >= deadline, "too early");
    transfer(total).to(Seller);
    commit();

    exit();
});