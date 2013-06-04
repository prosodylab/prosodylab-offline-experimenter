

function [choices] = getChoicesBracketings(condition);

bracketings{1}='abcd';
bracketings{2}='ab(cd)';
bracketings{3}='a(bc)d';
bracketings{4}='(ab)cd';
bracketings{5}='a(bcd)';
bracketings{6}='(ab)(cd)';
bracketings{7}='(abc)d';
bracketings{8}='a(b(cd))';
bracketings{9}='a((bc)d)';
bracketings{10}='(ab)c)d';
bracketings{11}='(a(bc))d';


options{1}=[1 6 7 11];
options{2}=[2 4 8 5];
options{3}=[3 6 9 1];
options{4}=[4 6 10 7];
options{5}=[5 2 11 8];
options{6}=[6 4 10 1];
options{7}=[7 3 10 9];
options{8}=[8 11 5 9];
options{9}=[ 9 8 10 5];
options{10}=[10 11 7 3];
options{11}=[ 11 10 7 9];

options{condition}(1)

choices{1}=bracketings{options{condition}(1)};
choices{2}=bracketings{options{condition}(2)};
choices{3}=bracketings{options{condition}(3)};
choices{4}=bracketings{options{condition}(4)};

end