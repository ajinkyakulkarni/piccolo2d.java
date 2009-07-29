/*
 * Copyright (c) 2008, Piccolo2D project, http://piccolo2d.org
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 * and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 * and the following disclaimer in the documentation and/or other materials provided with the
 * distribution.
 *
 * None of the name of the Piccolo2D project, the University of Maryland, or the names of its contributors
 * may be used to endorse or promote products derived from this software without specific prior written
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.piccolo2d.svg.cssmini;

import java.text.ParseException;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.piccolo2d.svg.util.RagelParser;

/** <a href="http://research.cs.queensu.ca/~thurston/ragel/">Ragel</a> parser 
 * for <a href="http://www.w3.org/TR/CSS21/grammar.html">CSS</a> - This file is auto-generated by rl2java.sh.
 * <p>
 * DO NOT EDIT MANUALLY!!!
 * </p>
 * See Also:<ul>
 * <li>Another CSS Grammar: http://www.w3.org/TR/CSS21/syndata.html</li>
 * <li>A ragel css grammar: http://labs.ohloh.net/ohcount/browser/ext/ohcount_native/ragel_parsers/css.rl?rev=83e15c94ca8c53994ef07cdb6c7a5ceffe67884c</li>
 * </ul>
 */
class CssSelectorToXPath implements RagelParser {
%%{

	machine selector;

	#######################################################
	## Define the actions
	#######################################################

	action start_element {
		if(debug) System.out.println("start_element");
		start = p;
	}
	action push_element {
		if(debug) System.out.println("push_element [" + new String(data, start, p-start) + "]");
		xpath.append('/').append(data, start, p-start);
		start = -1;
	}
	action push_wildcard {
		if(debug) System.out.println("push_wildcard");
		xpath.append("/*");
		start = -1;
	}
	action end_element {
		if(debug) System.out.println("end_element " + p);
		if(classes.size() > 0) {
			Collections.sort(classes);
			xpath.append("[@class='");
			Iterator it = classes.iterator();
			xpath.append(it.next());
			while(it.hasNext()) {
				xpath.append(' ').append(it.next());
			}
			xpath.append("']");
			classes.clear();
		}		
	}

	action start_class {
		if(debug) System.out.println("start_class");
		start = p;
	}
	action push_class {
		if(debug) System.out.println("push_class [" + new String(data, start, p-start) + "]");
		classes.add(new String(data, start, p-start));
		start = -1;
	}

	action push_combinator {
		if(debug) System.out.println("push_combinator [" + data[p] + "]");
		combinator = data[p];
	}
	action combined {
		if(debug) System.out.println("combined");
		switch(combinator) {
		case ' ': xpath.append('/'); break;
		case '>': break;
		default: throw new UnsupportedOperationException("Combinator [" + data[p] + "] not supported.");
		};
		combinator = ' ';
	}

	action end_selector {
		if(debug) System.out.println("end_selector [" + p + "] ");
	}

	#######################################################
	## Define the grammar
	#######################################################
		
	S = space;
	IDENT = [_a-zA-Z] ([_a-zA-Z0-9] | '-')*;

	element_name = (IDENT >start_element %push_element | "*" >push_wildcard) S*;

	class = "." IDENT >start_class %push_class S*;

	simple_selector = (element_name | class >push_wildcard) class* %end_element;

	combinator = ("+" | ">") $push_combinator S*;

	selector = simple_selector <: (combinator? simple_selector $1 %0 >combined)* %end_selector;
	
	main := S* selector %{if(debug) System.out.println("---");};
}%%

%% write data;

    final CharSequence parse(final CharSequence data) throws ParseException {
        return parse(data.toString().toCharArray());
    }

    final CharSequence parse(final char[] data) throws ParseException {
		// high-level buffers
        final List classes = new LinkedList();
        final StringBuilder xpath = new StringBuilder();
        char combinator = ' ';
		int start = -1;
		
		final boolean debug = false;
		
		// ragel variables (low level)
		final int pe = data.length;
		final int eof = pe;
		int cs, p = 0;

		%% write init;
		%% write exec;

		if (cs < selector_first_final)
			throw new ParseException(new String(data), p);
        return xpath.toString();
	}
}
