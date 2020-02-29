#include <cstdio>

#include <foo.h>

#include <SFML/Graphics.hpp>

void DoFoo()
{
	sf::RenderWindow window(sf::VideoMode(200, 200), "It works!");

	sf::CircleShape shape(100.0f);
	shape.setFillColor(sf::Color::Green);

	while (window.isOpen()) {
		sf::Event event;
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed) {
				window.close();
				break;
			}
		}

		window.clear();
		window.draw(shape);
		window.display();
	}
}
