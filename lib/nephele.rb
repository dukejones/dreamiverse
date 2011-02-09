class Nephele
  
  # responsible for single entry tag clouds, multi-entry tag clouds
  # and tag context clouds & tag scoring/storage
  
  # invoke processes for scoring custom tags and 
  # generating / scoring auto generated tags
  def process_single_entry_tags(dream)
    freqs = auto_generate_single_entry_tags(dream)
    add_stop_words
  end
  
  def auto_generate_single_entry_tags(dream)
    tags = dream.body.split(/\s+/) # make tags array by splitting body up
    freqs = score_freq(tags)
  end
  
  
  # return the noun (what) id for a tag if it exists or insert it and returns 
  # the new or id or return nil if invalid tag
  def get_what_id(what)
    #w = What.find_by_name(what)
    #w = What.create(name: what) if !w.id
    w = What.find_or_create_by_name(what)
    w.id 
  end  
  
  # takes in a normal array of keywords and returns hash of noun (what) ids
  # and their associated score/freq
  def score_freq(tags)
    freqs = {}
    # loop thru each tag, get a noun (what) id for each, then score frequencies
    tags.each do |tag|
      tag_id = nil #reset
      new_count = 0
      tag_id = get_what_id(tag) 
      
      if tag_id
        #new_count = 1 
        #new_count = freqs[tag_id] + 1
        if freqs.has_key?(tag_id)
          #new_count = freqs[tag_id] + 1  
          freqs[tag_id] = freqs[tag_id] + 1 # increment score for this tag id
        end
        #freqs[exists_id] = freqs[exists_id]++ if exists_id         
      end
    end
    return freqs
  end
  
  def add_stop_words
    stop_words = %w{able, about, above, according, accordingly, across, actually, after, afterwards, again, 
    against, ain't, all, allow, allows, almost, alone, along, already, also, although, always, am, among, amongst, an, and, 
    another, any, anybody, anyhow, anyone, anything, anyway, anyways, anywhere, apart, appear, appreciate, appropriate, are, 
    aren't, around, as, aside, ask, asking, associated, at, available, away, awfully, back, be, became, because, become, becomes, 
    becoming, been, before, beforehand, behind, being, believe, below, beside, besides, best, better, between, beyond, both, 
    brief, but, by, c'mon, c's, came, can, can't, cannot, cant, cause, causes, certain, certainly, changes, clearly, co, 
    com, come, comes, concerning, consequently, consider, considering, contain, containing, contains, corresponding, could, 
    couldn't, course, currently, definitely, described, despite, did, didn't, different, do, does, doesn't, doing, don't, 
    done, down, downwards, during, each, edu, eg, eight, either, else, elsewhere, enough, entirely, especially, et, etc, 
    even, ever, every, everybody, everyone, everything, everywhere, ex, exactly, example, except, far, few, fifth, first, 
    five, followed, following, follows, for, former, formerly, forth, four, from, further, furthermore, get, gets, getting, 
    given, gives, go, goes, going, gone, got, gotten, greetings, had, hadn't, happens, hardly, has, hasn't, have, haven't, 
    having, he, he's, hello, help, hence, her, here, here's, hereafter, hereby, herein, hereupon, hers, herself, hi, him, 
    himself, his, hither, hopefully, how, howbeit, however, i'd, i'll, i'm, i've, ie, if, ignored, immediate, in, inasmuch, 
    inc, indeed, indicate, indicated, indicates, inner, insofar, instead, into, inward, is, isn't, it, it'd, it'll, it's, its, 
    itself, just, keep, keeps, kept, know, knows, known, last, lately, later, latter, latterly, least, less, lest, let, let's, 
    like, liked, likely, little, look, looking, looks, ltd, mainly, many, may, maybe, me, mean, meanwhile, merely, might, more, 
    moreover, most, mostly, much, must, my, myself, name, namely, nd, near, nearly, necessary, need, needs, neither, never, 
    nevertheless, new, next, nine, no, nobody, non, none, noone, nor, normally, not, nothing, novel, now, nowhere, obviously, 
    of, off, often, oh, ok, okay, old, on, once, one, ones, only, onto, or, other, others, otherwise, ought, our, ours, 
    ourselves, out, outside, over, overall, own, particular, particularly, per, perhaps, placed, please, plus, possible, 
    presumably, probably, provides, que, quite, qv, rather, rd, re, really, reasonably, regarding, regardless, regards, 
    relatively, respectively, right, said, same, saw, say, saying, says, second, secondly, see, seeing, seem, seemed, seeming, 
    seems, seen, self, selves, sensible, sent, serious, seriously, seven, several, shall, she, should, shouldn't, since, six,
    so, some, somebody, somehow, someone, something, sometime, sometimes, somewhat, somewhere, soon, sorry, specified, specify, 
    specifying, still, sub, such, sup, sure, t's, take, taken, tell, tends, th, than, thank, thanks, thanx, that, that's, 
    thats, the, their, theirs, them, themselves, then, thence, there, there's, thereafter, thereby, therefore, therein, 
    theres, thereupon, these, they, they'd, they'll, they're, they've, think, third, this, thorough, thoroughly, those, though, 
    three, through, throughout, thru, thus, to, together, too, took, toward, towards, tried, tries, truly, try, trying, twice, 
    two, un, under, unfortunately, unless, unlikely, until, unto, up, upon, us, use, used, useful, uses, using, usually, value, 
    various, very, via, viz, vs, want, wants, was, wasn't, way, we, we'd, we'll, we're, we've, welcome, well, went, were, weren't, 
    what, what's, whatever, when, whence, whenever, where, where's, whereafter, whereas, whereby, wherein, whereupon, wherever, 
    whether, which, while, whither, who, who's, whoever, whole, whom, whose, why, will, willing, wish, with, within, without, 
    won't, wonder, would, would, wouldn't, yes, yet, you, you'd, you'll, you're, you've, your, yours, yourself, yourselves, zero,
    title,dream,body}
    
    stop_words.each do |word|
      if word.length > 2
        b = BlackListWord.new(name: word.strip, type: 'nephele') 
        b.save
      end
    end
  end
  
end