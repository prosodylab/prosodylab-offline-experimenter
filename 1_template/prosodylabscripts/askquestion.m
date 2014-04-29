
 %Ask User Question
        
 %Multiple Choice or Yes/No or Acceptability Judgment
 % Next one to be implemented: Picture Choice
        
        
 function [response] = askquestion(ws, settings, trial, qNumber)
        
 if qNumber == 1
     
     quText=trial.question;
     qType=trial.qType;
     
     if isfield(trial,'correctAnswer')
                correctAnswer=trial.correctAnswer;
                answer1=correctAnswer;             
     end
     
     if isfield(trial,'altAnswer1')
            answer2=trial.altAnswer1;
     end
     
     if isfield(trial,'altAnswer2')
            answer3= trial.altAnswer2;
     end
     
     if isfield(trial,'altAnswer3')
            answer4= trial.altAnswer3;
     end
                
    
 elseif qNumber == 2
     
     quText=trial.question2;
     qType=trial.qType2;
     
     if exist('trial.correctAnswer2')
                correctAnswer=trial.correctAnswer2;
                answer1=correctAnswer2;
     end
     
     if exist('trial.alt1Answer2')
            answer2=trial.alt1Answer2;
     end
     
     if exist('trial.alt2Answer2')
            answer3= trial.alt2Answer2;
     end
     
     if exist('trial.alt3Answer2')
            answer4= trial.alt3Answer2;
     end
     
     
 else 
     quText=trial.question3;
     qType=trial.qType3;
     
     if exist('trial.correctAnswer3')
                correctAnswer=trial.correctAnswer3;
                answer1=correctAnswer3;
     end
     
     if exist('trial.alt1Answer3')
            answer2=trial.alt1Answer3;
     end
     
     if exist('trial.alt2Answer3')
            answer3= trial.alt2Answer3;
     end
     
     if exist('trial.alt3Answer3')
            answer4= trial.alt3Answer3;
     end
 end
 
 
 accepted_keys=settings.acceptedkeys;
        
        if (strcmp(qType,'yn'))
            %yes/no question
            
           
            Screen('DrawText', ws.ptr, double(quText),50,[settings.messageheight-200]);
            
            quAsk=settings.message4;
            Screen('DrawText', ws.ptr, double(QuText),50,settings.messageheight);
            
            Screen('Flip',ws.ptr);
            [pressed_key resp_time] = getKeyResponse(accepted_keys,inf);
            
            if length(pressed_key)>1
               pressed_key=pressed_key(1);
            end
            %pressed_key=str2num(pressed_key);
            %user_answer=num2str(pressed_key);
            
            if trial.correctAnswer=='y'
                correctAnswer='1';
            else
                correctAnswer='0';
            end
            
            user_answer=pressed_key;
            check_answer=strcmp(user_answer, correctAnswer);
            
        elseif (strcmp(qType,'jm'))
            
            % acceptability judgment
            % ratingtext = 'Please rate the sentence between 1 (completely unacceptable) and 5 (completely acceptable).';
            
            correctAnswer='';
            
            quAsk=quText;
            DrawFormattedText(ws.ptr,double(quAsk), 'center','center', 0);
            Screen('Flip',ws.ptr);
            [pressed_key resp_time] = getResponseKeypad(accepted_keys,inf);
            FlushEvents('keyDown');
            pressed_key=str2num(pressed_key);
        
            user_answer=num2str(pressed_key);
            check_answer=' ';
        elseif (strcmp(qType,'mc'))||(strcmp(qType,'mcF'))
            
            %Multiple Choice
            
            if (strcmp(qType,'mc'))
                rand_index=randperm(trial.nChoices);
            elseif (strcmp(qType,'mcF'))
                rand_index=1:trial.nChoices;
            end
            
            if trial.nChoices==2
                    
                 rand_index=randperm(2);
                 answer_array={answer1 answer2};
                 mc_options=strcat(quText,'\n\n\n',' 1.  ',answer_array{rand_index(1)},'\n\n',' 2.  ',answer_array{rand_index(2)});
                 
            elseif trial.nChoices==3
                
                rand_index=randperm(3);
                answer_array={answer1 answer2 answer3};
                
                mc_options=strcat('1. ',answer_array{rand_index(1)},'\n\n','2.  ',answer_array{rand_index(2)},'\n', answer_array{rand_index(3)},'\n\n\n',quText);
       
            else
                
                rand_index=randperm(4);
                answer_array={answer1 answer2 answer3 answer4};
                
                mc_options=strcat('1. ',answer_array{rand_index(1)},'\n\n','2. ',answer_array{rand_index(2)},'\n', answer_array{rand_index(3)},'\n', answer_array{rand_index(4)},'\n\n\n',quText);
            
            end
            
            DrawFormattedText(ws.ptr,mc_options, 'center','center', 0);
            Screen('Flip',ws.ptr);
            %Retrieve user's selection
            [pressed_key resp_time]= getResponseKeypad(accepted_keys,inf);
            pressed_key=str2num(pressed_key);
            %Convert number answer to sentence text
            if pressed_key<min(rand_index)||pressed_key>max(rand_index)
                user_answer='';
            else
                user_answer=answer_array{rand_index(pressed_key)};    
            end
            
            check_answer=strcmp(user_answer, correctAnswer);
            
            
        elseif (strcmp(qType,'brack'))
            
            %quText='Which bracketing does the response have?';
            
            choices=getChoicesBracketings(trial.condition);
            
            correctAnswer=choices{1};
            
            answer1=choices{1};
            answer2=choices{2};
            answer3=choices{3};
            answer4=choices{4};
            
            rand_index=randperm(4);
            answer_array={answer1 answer2 answer3 answer4};
            
            mc_options=strcat('1. ',answer_array{rand_index(1)},'\n\n','2. ',answer_array{rand_index(2)},'\n\n', '3. ', answer_array{rand_index(3)},'\n\n', '4. ',answer_array{rand_index(4)},'\n\n\n',quText);
          
            
            DrawFormattedText(ws.ptr,mc_options, 'center','center', 0);
            Screen('Flip',ws.ptr);
            %Retrieve user's selection
            [pressed_key resp_time]= getResponseKeypad(accepted_keys,inf);
            pressed_key=str2num(pressed_key);
            
            display(pressed_key);
            
            %Convert number answer to sentence text
            if pressed_key==1
                user_answer=answer_array{rand_index(1)};
            elseif pressed_key==2
                user_answer=answer_array{rand_index(2)};
            elseif pressed_key==3
                user_answer=answer_array{rand_index(3)};
            elseif pressed_key==4
                user_answer=answer_array{rand_index(4)};
            else
                user_answer='wrong key';
            end
            
            
            check_answer=strcmp(user_answer, correctAnswer);
            
            
        else
            clear screen;
            display('Don''t know question!');
        end
        
        % Save results in structure
        if qNumber == 1
            
            trial.response=user_answer;
            trial.correct=num2str(check_answer);
            trial.rt=num2str(resp_time);
        elseif qNumber==2
            trial.response2=num2str(user_answer);
            trial.correct2=num2str(check_answer);
            trial.rt2=num2str(resp_time);
        else
            trial.response3=num2str(user_answer);
            trial.correct3=num2str(check_answer);
            trial.rt3=num2str(resp_time);
        end
        
        response=trial;

        end
      