script "libramvalues.ash";
notify "soolar the second";

int LIBRAM_CANDY_HEARTS = 0;
boolean [item] ITEMS_CANDY_HEARTS = $items[white candy heart, pink candy heart, orange candy heart, lavender candy heart, yellow candy heart, green candy heart];
int LIBRAM_PARTY_FAVORS = 1;
boolean [item] ITEMS_PARTY_FAVORS_COMMON = $items[divine noisemaker, divine can of silly string, divine blowout];
boolean [item] ITEMS_PARTY_FAVORS_UNCOMMON = $items[divine champagne flute, divine champagne popper, divine cracker];
int LIBRAM_LOVE_SONGS = 2;
boolean [item] ITEMS_LOVE_SONGS = $items[love song of vague ambiguity, love song of smoldering passion, love song of icy revenge, love song of sugary cuteness, love song of disturbing obsession, love song of naughty innuendo];
int LIBRAM_BRICKOS = 3;
int LIBRAM_DICE = 4;
boolean [item] ITEMS_DICE = $items[d4, d6, d8, d10, d12, d20];
int LIBRAM_RESOLUTIONS = 5;
boolean [item] ITEMS_RESOLUTIONS_COMMON = $items[resolution: be wealthier, resolution: be happier, resolution: be feistier, resolution: be stronger, resolution: be smarter, resolution: be sexier];
boolean [item] ITEMS_RESOLUTIONS_UNCOMMON = $items[resolution: be kinder, resolution: be luckier, resolution: be more adventurous];
int LIBRAM_TAFFY = 6;
boolean [item] ITEMS_TAFFY_COMMON = $items[pulled red taffy, pulled orange taffy, pulled blue taffy, pulled violet taffy];
boolean [item] ITEMS_TAFFY_UNCOMMON_PRE_YELLOW = $items[pulled yellow taffy, pulled green taffy, pulled indigo taffy];
boolean [item] ITEMS_TAFFY_UNCOMMON_POST_YELLOW = $items[pulled green taffy, pulled indigo taffy];
int LIBRAM_COUNT = 7;

skill libram_id_to_skill(int libram)
{
	switch(libram)
	{
	case LIBRAM_CANDY_HEARTS: return $skill[summon candy heart];
	case LIBRAM_PARTY_FAVORS: return $skill[summon party favor];
	case LIBRAM_LOVE_SONGS: return $skill[summon love song];
	case LIBRAM_BRICKOS: return $skill[summon brickos];
	case LIBRAM_DICE: return $skill[summon dice];
	case LIBRAM_RESOLUTIONS: return $skill[summon resolutions];
	case LIBRAM_TAFFY: return $skill[summon taffy];
	}
	return $skill[none];
}

boolean libram_is_static_value(int libram)
{
	switch(libram)
	{
	case LIBRAM_CANDY_HEARTS: return true;
	case LIBRAM_PARTY_FAVORS: return false;
	case LIBRAM_LOVE_SONGS: return true;
	case LIBRAM_BRICKOS: return get_property("_brickoEyeSummons").to_int() >= 3;
	case LIBRAM_DICE: return true;
	case LIBRAM_RESOLUTIONS: return true;
	case LIBRAM_TAFFY: return false;
	}
	return false;
}

float average_value(boolean [item] its)
{
	int count = 0;
	float value = 0;
	foreach it in its
	{
		++count;
		value += mall_price(it);
	}
	return value / count;
}

float libram_value(int libram)
{
	switch(libram)
	{
	case LIBRAM_CANDY_HEARTS:
		return average_value(ITEMS_CANDY_HEARTS);
	case LIBRAM_PARTY_FAVORS:
	{
		float uncommon_chance = 0.5;
		for(int i = 0; i < get_property("_favorRareSummons").to_int(); ++i)
		{
			uncommon_chance /= 2;
		}
		return (1 - uncommon_chance) * average_value(ITEMS_PARTY_FAVORS_COMMON) + uncommon_chance * average_value(ITEMS_PARTY_FAVORS_UNCOMMON);
	}
	case LIBRAM_LOVE_SONGS:
		return average_value(ITEMS_LOVE_SONGS);
	case LIBRAM_BRICKOS:
	{
		float plain_value = mall_price($item[BRICKO brick]);
		float eye_value = mall_price($item[BRICKO eye brick]);
		float common_value = 3 * plain_value;
		float uncommon_value = 2 * plain_value + eye_value;
		int eyes_summoned = get_property("_brickoEyeSummons").to_int();
		if(eyes_summoned <= 0)
		{
			return (common_value + uncommon_value) / 2;
		}
		else if(eyes_summoned < 3)
		{
			return (2 * common_value + uncommon_value) / 3;
		}
		else
		{
			return common_value;
		}
	}
	case LIBRAM_DICE:
		return average_value(ITEMS_DICE);
	case LIBRAM_RESOLUTIONS:
		return 0.98 * average_value(ITEMS_RESOLUTIONS_COMMON) + 0.02 * average_value(ITEMS_RESOLUTIONS_UNCOMMON);
	case LIBRAM_TAFFY:
	{
		boolean yellow_summoned = (get_property("_taffyYellowSummons").to_int() > 0);
		float common_value = average_value(ITEMS_TAFFY_COMMON);
		float uncommon_value = average_value(yellow_summoned ? ITEMS_TAFFY_UNCOMMON_POST_YELLOW : ITEMS_TAFFY_UNCOMMON_PRE_YELLOW);
		float uncommon_chance = 0.5;
		for(int i = 0; i < get_property("_taffyRareSummons").to_int(); ++i)
		{
			uncommon_chance /= 2;
		}
		return (1 - uncommon_chance) * common_value + uncommon_chance * uncommon_value;
	}
	default:
		abort("INVALID LIBRAM ID " + libram);
	}
	return 0;
}

float libram_value_floor(int libram)
{
	switch(libram)
	{
	case LIBRAM_PARTY_FAVORS: return average_value(ITEMS_PARTY_FAVORS_COMMON);
	case LIBRAM_BRICKOS: return 3 * mall_price($item[BRICKO brick]);
	case LIBRAM_TAFFY: return average_value(ITEMS_TAFFY_COMMON);
	default: return libram_value(libram);
	}
}

skill most_profitable_libram(boolean owned_only)
{
	int best = -1;
	int best_value = 0;
	for(int id = 0; id < LIBRAM_COUNT; ++id)
	{
		if(owned_only && !have_skill(libram_id_to_skill(id)))
		{
			continue;
		}
		float value = libram_value(id);
		if(value > best_value)
		{
			best_value = value;
			best = id;
		}
	}
	return libram_id_to_skill(best);
}

void libram_burn_down_to(int mp)
{
	skill best = most_profitable_libram(true);
	while(best != $skill[none] && my_mp() - mp >= mp_cost(best))
	{
		use_skill(1, best);
		best = most_profitable_libram(true);
	}
}

void main()
{
	print("CURRENT average libram summon values.", "blue");
	print("This may change as you summon uncommons, unless otherwise noted", "blue");
	int [int] sorted;
	for(int id = 0; id < LIBRAM_COUNT; ++id)
	{
		sorted[id] = id;
	}

	sort sorted by libram_value(value);

	foreach i, id in sorted
	{
		float value = libram_value(id);
		skill libram_skill = libram_id_to_skill(id);
		buffer out;
		out.append(libram_skill.to_string());
		out.append(': <span style="color: ');
		out.append(have_skill(libram_skill) ? 'green' : 'red');
		out.append(';">');
		out.append(value);
		out.append('</span> (');
		out.append(libram_is_static_value(id) ? 'will not change today' : ('approaching ' + libram_value_floor(id)));
		out.append(')');
		print_html(out.to_string());
	}
}
